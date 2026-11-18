import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/model_json.dart';
import '../models/assistant_conversation.dart';
import '../models/assistant_document.dart';
import '../models/assistant_saved_item.dart';
import '../models/assistant_state.dart';
import '../models/assistant_usage.dart';
import '../models/assistant_voice_entry.dart';

class AssistantLocalStore {
  const AssistantLocalStore();

  static const storageKey = 'naru.ai.assistant.v1';

  Future<AssistantState> load({DateTime? now}) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(storageKey);
    if (stored == null) return _emptyState(now ?? DateTime.now());

    final decoded = jsonDecode(stored);
    final json = ModelJson.object(decoded, 'assistant state');
    if (ModelJson.requiredInt(json, 'version') != 1) {
      throw const FormatException('Unsupported assistant data version.');
    }

    final usage = AssistantUsage.fromJson(
      ModelJson.object(json['usage'], 'usage'),
    );
    return AssistantState(
      conversations: ModelJson.objectList(
        json,
        'conversations',
        AssistantConversation.fromJson,
      ),
      documents: ModelJson.objectList(
        json,
        'documents',
        AssistantDocument.fromJson,
      ),
      voiceHistory: ModelJson.objectList(
        json,
        'voiceHistory',
        AssistantVoiceEntry.fromJson,
      ),
      savedItems: json['savedItems'] == null
          ? const []
          : ModelJson.objectList(
              json,
              'savedItems',
              AssistantSavedItem.fromJson,
            ),
      usage: usage.forDate(now ?? DateTime.now()),
    );
  }

  Future<void> save(AssistantState state) async {
    final preferences = await SharedPreferences.getInstance();
    final document = {
      'version': 1,
      'conversations': state.conversations
          .map((conversation) => conversation.toJson())
          .toList(),
      'documents': state.documents
          .map((document) => document.toJson())
          .toList(),
      'voiceHistory': state.voiceHistory
          .map((entry) => entry.toJson())
          .toList(),
      'savedItems': state.savedItems
          .map((item) => item.toJson())
          .toList(),
      'usage': state.usage.toJson(),
    };
    final saved = await preferences.setString(storageKey, jsonEncode(document));
    if (!saved) {
      throw StateError('Assistant data could not be saved.');
    }
  }

  AssistantState _emptyState(DateTime now) => AssistantState(
    conversations: const [],
    documents: const [],
    voiceHistory: const [],
    savedItems: const [],
    usage: AssistantUsage.today(now),
  );
}
