import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/ai_assistant/data/assistant_local_store.dart';
import 'package:naru/features/ai_assistant/models/assistant_conversation.dart';
import 'package:naru/features/ai_assistant/models/assistant_document.dart';
import 'package:naru/features/ai_assistant/models/assistant_message.dart';
import 'package:naru/features/ai_assistant/models/assistant_mode.dart';
import 'package:naru/features/ai_assistant/models/assistant_state.dart';
import 'package:naru/features/ai_assistant/models/assistant_usage.dart';
import 'package:naru/features/ai_assistant/models/assistant_voice_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'persists conversations, documents, voice previews, and usage',
    () async {
      SharedPreferences.setMockInitialValues({});
      const store = AssistantLocalStore();
      final now = DateTime(2026, 11, 17, 10);
      final state = AssistantState(
        conversations: [
          AssistantConversation(
            id: 'conversation-1',
            title: 'Apprendre Dart',
            mode: AssistantMode.learn,
            messages: [
              AssistantMessage(
                id: 'message-1',
                content: 'Explique les variables.',
                sender: AssistantMessageSender.user,
                createdAt: now,
              ),
            ],
            createdAt: now,
            updatedAt: now,
            isFavorite: true,
          ),
        ],
        documents: [
          AssistantDocument(
            id: 'document-1',
            name: 'notes.txt',
            format: 'TXT',
            sizeLabel: '4 Ko',
            addedAt: now,
          ),
        ],
        voiceHistory: [
          AssistantVoiceEntry(
            id: 'voice-1',
            exampleText: 'Texte non reconnu.',
            createdAt: now,
          ),
        ],
        usage: AssistantUsage(
          dateKey: '2026-11-17',
          counts: {AssistantQuotaKind.messages: 2},
        ),
      );

      await store.save(state);
      final loaded = await store.load(now: now);

      expect(
        loaded.conversations.single.toJson(),
        state.conversations.single.toJson(),
      );
      expect(loaded.documents.single.name, 'notes.txt');
      expect(loaded.voiceHistory.single.exampleText, 'Texte non reconnu.');
      expect(loaded.usage.count(AssistantQuotaKind.messages), 2);
    },
  );

  test('resets daily usage on a new local date', () async {
    SharedPreferences.setMockInitialValues({});
    const store = AssistantLocalStore();
    await store.save(
      AssistantState(
        conversations: const [],
        documents: const [],
        voiceHistory: const [],
        usage: AssistantUsage(
          dateKey: '2026-11-16',
          counts: {AssistantQuotaKind.messages: 12},
        ),
      ),
    );

    final loaded = await store.load(now: DateTime(2026, 11, 17));

    expect(loaded.usage.count(AssistantQuotaKind.messages), 0);
    expect(loaded.usage.dateKey, '2026-11-17');
  });

  test('rejects malformed local assistant data', () async {
    SharedPreferences.setMockInitialValues({
      AssistantLocalStore.storageKey: '{"version":1,"usage":false}',
    });

    await expectLater(
      const AssistantLocalStore().load(),
      throwsFormatException,
    );
  });
}
