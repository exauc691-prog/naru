import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/ai_assistant/data/assistant_local_store.dart';
import 'package:naru/features/ai_assistant/data/assistant_quota_config.dart';
import 'package:naru/features/ai_assistant/models/assistant_mode.dart';
import 'package:naru/features/ai_assistant/models/assistant_message.dart';
import 'package:naru/features/ai_assistant/models/assistant_state.dart';
import 'package:naru/features/ai_assistant/models/assistant_usage.dart';
import 'package:naru/features/ai_assistant/providers/assistant_providers.dart';
import 'package:naru/features/subscription/data/local_subscription_repository.dart';
import 'package:naru/features/subscription/models/subscription_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'starts and updates a local conversation with quota accounting',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(assistantControllerProvider.future);
      final controller = container.read(assistantControllerProvider.notifier);

      final id = await controller.startConversation(
        mode: AssistantMode.learn,
        content: 'Explique les fractions.',
      );
      await controller.sendMessage(id, 'Donne un exemple.');
      final state = container.read(assistantControllerProvider).requireValue;
      final conversation = state.conversations.single;

      expect(conversation.id, id);
      expect(conversation.messages, hasLength(4));
      expect(
        conversation.messages[1].content,
        contains('Démonstration locale'),
      );
      expect(state.usage.count(AssistantQuotaKind.messages), 2);
    },
  );

  test('edits, regenerates, and rates the latest local response', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(assistantControllerProvider.future);
    final controller = container.read(assistantControllerProvider.notifier);
    final id = await controller.startConversation(
      mode: AssistantMode.learn,
      content: 'Question initiale',
    );

    var conversation = container
        .read(assistantControllerProvider)
        .requireValue
        .conversations
        .single;
    await controller.editLastQuestion(
      id,
      conversation.messages.first.id,
      'Question reformulée',
    );
    await controller.regenerateResponse(id);
    conversation = container
        .read(assistantControllerProvider)
        .requireValue
        .conversations
        .single;
    await controller.setFeedback(
      id,
      conversation.messages.last.id,
      AssistantMessageFeedback.helpful,
    );

    conversation = container
        .read(assistantControllerProvider)
        .requireValue
        .conversations
        .single;
    expect(conversation.title, 'Question reformulée');
    expect(conversation.messages, hasLength(2));
    expect(conversation.messages.first.content, 'Question reformulée');
    expect(
      conversation.messages.last.feedback,
      AssistantMessageFeedback.helpful,
    );
    expect(
      container
          .read(assistantControllerProvider)
          .requireValue
          .usage
          .count(AssistantQuotaKind.messages),
      3,
    );
  });

  test(
    'rejects a capped request without creating a partial conversation',
    () async {
      SharedPreferences.setMockInitialValues({
        LocalSubscriptionRepository.preferenceKey: SubscriptionPlan.free.name,
      });
      const store = AssistantLocalStore();
      await store.save(
        AssistantState(
          conversations: const [],
          documents: const [],
          voiceHistory: const [],
          usage: AssistantUsage(
            dateKey: _todayKey(),
            counts: {AssistantQuotaKind.messages: 20},
          ),
        ),
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(assistantControllerProvider.future);

      await expectLater(
        container
            .read(assistantControllerProvider.notifier)
            .startConversation(mode: AssistantMode.learn, content: 'Question'),
        throwsA(isA<AssistantQuotaExceeded>()),
      );
      expect(
        container.read(assistantControllerProvider).requireValue.conversations,
        isEmpty,
      );
    },
  );
}

String _todayKey() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}
