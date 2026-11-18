import 'assistant_conversation.dart';
import 'assistant_document.dart';
import 'assistant_saved_item.dart';
import 'assistant_usage.dart';
import 'assistant_voice_entry.dart';

class AssistantState {
  AssistantState({
    required List<AssistantConversation> conversations,
    required List<AssistantDocument> documents,
    required List<AssistantVoiceEntry> voiceHistory,
    List<AssistantSavedItem> savedItems = const [],
    required this.usage,
  }) : conversations = List.unmodifiable(conversations),
       documents = List.unmodifiable(documents),
       voiceHistory = List.unmodifiable(voiceHistory),
       savedItems = List.unmodifiable(savedItems);

  final List<AssistantConversation> conversations;
  final List<AssistantDocument> documents;
  final List<AssistantVoiceEntry> voiceHistory;
  final List<AssistantSavedItem> savedItems;
  final AssistantUsage usage;

  AssistantState copyWith({
    List<AssistantConversation>? conversations,
    List<AssistantDocument>? documents,
    List<AssistantVoiceEntry>? voiceHistory,
    List<AssistantSavedItem>? savedItems,
    AssistantUsage? usage,
  }) => AssistantState(
    conversations: conversations ?? this.conversations,
    documents: documents ?? this.documents,
    voiceHistory: voiceHistory ?? this.voiceHistory,
    savedItems: savedItems ?? this.savedItems,
    usage: usage ?? this.usage,
  );
}
