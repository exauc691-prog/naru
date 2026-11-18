import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../data/ai_model_catalog.dart';
import '../data/assistant_demo_service.dart';
import '../data/assistant_local_store.dart';
import '../data/assistant_quota_config.dart';
import '../models/assistant_conversation.dart';
import '../models/assistant_document.dart';
import '../models/assistant_message.dart';
import '../models/assistant_mode.dart';
import '../models/assistant_saved_item.dart';
import '../models/assistant_state.dart';
import '../models/assistant_usage.dart';
import '../models/assistant_voice_entry.dart';

final assistantLocalStoreProvider = Provider<AssistantLocalStore>(
  (ref) => const AssistantLocalStore(),
);

final assistantDemoServiceProvider = Provider<AssistantDemoService>(
  (ref) => const AssistantDemoService(),
);

final assistantQuotaConfigProvider = Provider<AssistantQuotaConfig>(
  (ref) => const AssistantQuotaConfig(),
);

final aiModelCatalogProvider = Provider<AIModelCatalog>(
  (ref) => const AIModelCatalog([]),
);

final assistantControllerProvider =
    AsyncNotifierProvider<AssistantController, AssistantState>(
      AssistantController.new,
    );

class AssistantController extends AsyncNotifier<AssistantState> {
  @override
  Future<AssistantState> build() =>
      ref.read(assistantLocalStoreProvider).load();

  Future<String> createConversation({required AssistantMode mode}) async {
    final current = state.requireValue;
    final now = DateTime.now();
    final id = _newId('conversation');
    final conversation = AssistantConversation(
      id: id,
      title: 'Nouvelle conversation',
      mode: mode,
      messages: const [],
      createdAt: now,
      updatedAt: now,
    );
    await _save(
      current.copyWith(conversations: [conversation, ...current.conversations]),
    );
    return id;
  }

  Future<String> startConversation({
    required AssistantMode mode,
    required String content,
    AssistantQuotaKind? additionalQuotaKind,
  }) async {
    final prompt = content.trim();
    if (prompt.isEmpty) throw ArgumentError.value(content, 'content');
    final current = _today(state.requireValue);
    final plan = await ref.read(subscriptionPlanProvider.future);
    var usage = _consume(current.usage, plan, AssistantQuotaKind.messages);
    if (additionalQuotaKind != null) {
      usage = _consume(usage, plan, additionalQuotaKind);
    }
    final id = _newId('conversation');
    final now = DateTime.now();
    final userMessage = AssistantMessage(
      id: _newId('message'),
      content: prompt,
      sender: AssistantMessageSender.user,
      createdAt: now,
    );
    final response = await ref
        .read(assistantDemoServiceProvider)
        .createResponse(mode, prompt);
    final conversation = AssistantConversation(
      id: id,
      title: _titleFrom(prompt),
      mode: mode,
      messages: [
        userMessage,
        AssistantMessage(
          id: _newId('message'),
          content: response,
          sender: AssistantMessageSender.assistant,
          createdAt: DateTime.now(),
        ),
      ],
      createdAt: now,
      updatedAt: DateTime.now(),
    );
    await _save(
      current.copyWith(
        conversations: [conversation, ...current.conversations],
        usage: usage,
      ),
    );
    return id;
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final prompt = content.trim();
    if (prompt.isEmpty) return;
    final current = _today(state.requireValue);
    final plan = await ref.read(subscriptionPlanProvider.future);
    final usage = _consume(current.usage, plan, AssistantQuotaKind.messages);
    final index = current.conversations.indexWhere(
      (item) => item.id == conversationId,
    );
    if (index < 0) throw StateError('Conversation not found: $conversationId');

    final conversation = current.conversations[index];
    final userMessage = AssistantMessage(
      id: _newId('message'),
      content: prompt,
      sender: AssistantMessageSender.user,
      createdAt: DateTime.now(),
    );
    final response = await ref
        .read(assistantDemoServiceProvider)
        .createResponse(conversation.mode, prompt);
    final assistantMessage = AssistantMessage(
      id: _newId('message'),
      content: response,
      sender: AssistantMessageSender.assistant,
      createdAt: DateTime.now(),
    );
    final messages = [...conversation.messages, userMessage, assistantMessage];
    final updatedConversation = conversation.copyWith(
      title: conversation.messages.isEmpty
          ? _titleFrom(prompt)
          : conversation.title,
      messages: messages,
      updatedAt: DateTime.now(),
    );
    final conversations = [...current.conversations]
      ..[index] = updatedConversation;
    await _save(current.copyWith(conversations: conversations, usage: usage));
  }

  Future<void> regenerateResponse(String conversationId) async {
    final current = _today(state.requireValue);
    final plan = await ref.read(subscriptionPlanProvider.future);
    final usage = _consume(current.usage, plan, AssistantQuotaKind.messages);
    final index = current.conversations.indexWhere(
      (item) => item.id == conversationId,
    );
    if (index < 0) throw StateError('Conversation not found: $conversationId');
    final conversation = current.conversations[index];
    final userIndex = conversation.messages.lastIndexWhere(
      (message) => message.sender == AssistantMessageSender.user,
    );
    if (userIndex < 0) {
      throw StateError('Conversation has no question to regenerate.');
    }

    final userMessage = conversation.messages[userIndex];
    final response = await ref
        .read(assistantDemoServiceProvider)
        .createResponse(conversation.mode, userMessage.content);
    final messages = [
      ...conversation.messages.take(userIndex + 1),
      AssistantMessage(
        id: _newId('message'),
        content: response,
        sender: AssistantMessageSender.assistant,
        createdAt: DateTime.now(),
      ),
    ];
    final conversations = [...current.conversations]
      ..[index] = conversation.copyWith(
        messages: messages,
        updatedAt: DateTime.now(),
      );
    await _save(current.copyWith(conversations: conversations, usage: usage));
  }

  Future<void> editLastQuestion(
    String conversationId,
    String messageId,
    String content,
  ) async {
    final prompt = content.trim();
    if (prompt.isEmpty) return;
    final current = _today(state.requireValue);
    final plan = await ref.read(subscriptionPlanProvider.future);
    final usage = _consume(current.usage, plan, AssistantQuotaKind.messages);
    final index = current.conversations.indexWhere(
      (item) => item.id == conversationId,
    );
    if (index < 0) throw StateError('Conversation not found: $conversationId');
    final conversation = current.conversations[index];
    final userIndex = conversation.messages.lastIndexWhere(
      (message) => message.sender == AssistantMessageSender.user,
    );
    if (userIndex < 0 || conversation.messages[userIndex].id != messageId) {
      throw StateError('Only the latest question can be edited.');
    }

    final previous = conversation.messages[userIndex];
    final revisedQuestion = previous.copyWith(
      content: prompt,
      clearFeedback: true,
    );
    final response = await ref
        .read(assistantDemoServiceProvider)
        .createResponse(conversation.mode, prompt);
    final messages = [
      ...conversation.messages.take(userIndex),
      revisedQuestion,
      AssistantMessage(
        id: _newId('message'),
        content: response,
        sender: AssistantMessageSender.assistant,
        createdAt: DateTime.now(),
      ),
    ];
    final conversations = [...current.conversations]
      ..[index] = conversation.copyWith(
        title: userIndex == 0 ? _titleFrom(prompt) : null,
        messages: messages,
        updatedAt: DateTime.now(),
      );
    await _save(current.copyWith(conversations: conversations, usage: usage));
  }

  Future<void> setFeedback(
    String conversationId,
    String messageId,
    AssistantMessageFeedback? feedback,
  ) async {
    final current = state.requireValue;
    final conversations = current.conversations.map((conversation) {
      if (conversation.id != conversationId) return conversation;
      return conversation.copyWith(
        messages: conversation.messages
            .map(
              (message) => message.id == messageId
                  ? message.copyWith(
                      feedback: feedback,
                      clearFeedback: feedback == null,
                    )
                  : message,
            )
            .toList(),
      );
    }).toList();
    await _save(current.copyWith(conversations: conversations));
  }

  Future<void> toggleFavorite(String conversationId) async {
    final current = state.requireValue;
    final conversations = current.conversations.map((conversation) {
      return conversation.id == conversationId
          ? conversation.copyWith(isFavorite: !conversation.isFavorite)
          : conversation;
    }).toList();
    await _save(current.copyWith(conversations: conversations));
  }

  Future<void> renameConversation(String conversationId, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(title, 'title');
    final current = state.requireValue;
    final conversations = current.conversations.map((conversation) {
      return conversation.id == conversationId
          ? conversation.copyWith(title: trimmed, updatedAt: DateTime.now())
          : conversation;
    }).toList();
    await _save(current.copyWith(conversations: conversations));
  }

  Future<void> deleteConversation(String conversationId) async {
    final current = state.requireValue;
    await _save(
      current.copyWith(
        conversations: current.conversations
            .where((conversation) => conversation.id != conversationId)
            .toList(),
      ),
    );
  }

  Future<void> clearPersonalData() async {
    final current = state.requireValue;
    await _save(
      current.copyWith(
        conversations: const [],
        documents: const [],
        voiceHistory: const [],
        savedItems: const [],
      ),
    );
  }

  Future<void> saveResponse({
    required String conversationId,
    required String messageId,
  }) async {
    final current = state.requireValue;
    AssistantConversation? conversation;
    AssistantMessage? message;
    for (final item in current.conversations) {
      if (item.id == conversationId) {
        conversation = item;
        for (final candidate in item.messages) {
          if (candidate.id == messageId &&
              candidate.sender == AssistantMessageSender.assistant) {
            message = candidate;
            break;
          }
        }
        break;
      }
    }
    if (conversation == null || message == null) {
      throw StateError('Response not found.');
    }
    if (current.savedItems.any((item) => item.id == messageId)) return;

    final title = conversation.title;
    final saved = AssistantSavedItem(
      id: messageId,
      title: title,
      content: message.content,
      category: conversation.mode.category,
      createdAt: DateTime.now(),
    );
    await _save(
      current.copyWith(savedItems: [saved, ...current.savedItems]),
    );
  }

  Future<void> deleteSavedItem(String itemId) async {
    final current = state.requireValue;
    await _save(
      current.copyWith(
        savedItems: current.savedItems
            .where((item) => item.id != itemId)
            .toList(),
      ),
    );
  }

  Future<void> addDocument({
    required String name,
    required String format,
    required String sizeLabel,
  }) async {
    final current = state.requireValue;
    final document = AssistantDocument(
      id: _newId('document'),
      name: name,
      format: format,
      sizeLabel: sizeLabel,
      addedAt: DateTime.now(),
    );
    await _save(current.copyWith(documents: [document, ...current.documents]));
  }

  Future<void> deleteDocument(String documentId) async {
    final current = state.requireValue;
    await _save(
      current.copyWith(
        documents: current.documents
            .where((document) => document.id != documentId)
            .toList(),
      ),
    );
  }

  Future<void> recordVoicePreview(String exampleText) async {
    final current = state.requireValue;
    final entry = AssistantVoiceEntry(
      id: _newId('voice'),
      exampleText: exampleText,
      createdAt: DateTime.now(),
    );
    await _save(
      current.copyWith(voiceHistory: [entry, ...current.voiceHistory]),
    );
  }

  Future<void> recordQuotaUse(AssistantQuotaKind kind) async {
    final current = _today(state.requireValue);
    final plan = await ref.read(subscriptionPlanProvider.future);
    final usage = _consume(current.usage, plan, kind);
    await _save(current.copyWith(usage: usage));
  }

  AssistantUsage _consume(
    AssistantUsage usage,
    SubscriptionPlan plan,
    AssistantQuotaKind kind,
  ) {
    final limit = ref.read(assistantQuotaConfigProvider).limitFor(plan, kind);
    if (usage.count(kind) >= limit) {
      throw AssistantQuotaExceeded(kind: kind, limit: limit, plan: plan);
    }
    return usage.increment(kind);
  }

  AssistantState _today(AssistantState current) =>
      current.copyWith(usage: current.usage.forDate(DateTime.now()));

  Future<void> _save(AssistantState next) async {
    await ref.read(assistantLocalStoreProvider).save(next);
    state = AsyncData(next);
  }
}

String _newId(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}';

String _titleFrom(String prompt) {
  final normalized = prompt.replaceAll(RegExp(r'\s+'), ' ').trim();
  return normalized.length <= 42
      ? normalized
      : '${normalized.substring(0, 39)}…';
}
