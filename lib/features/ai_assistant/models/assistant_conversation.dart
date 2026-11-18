import '../../../shared/models/model_json.dart';
import 'assistant_message.dart';
import 'assistant_mode.dart';

class AssistantConversation {
  AssistantConversation({
    required this.id,
    required this.title,
    required this.mode,
    required List<AssistantMessage> messages,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  }) : messages = List.unmodifiable(messages);

  final String id;
  final String title;
  final AssistantMode mode;
  final List<AssistantMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  AssistantConversation copyWith({
    String? title,
    AssistantMode? mode,
    List<AssistantMessage>? messages,
    DateTime? updatedAt,
    bool? isFavorite,
  }) => AssistantConversation(
    id: id,
    title: title ?? this.title,
    mode: mode ?? this.mode,
    messages: messages ?? this.messages,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isFavorite: isFavorite ?? this.isFavorite,
  );

  factory AssistantConversation.fromJson(ModelJsonMap json) =>
      AssistantConversation(
        id: ModelJson.requiredString(json, 'id'),
        title: ModelJson.requiredString(json, 'title'),
        mode: ModelJson.enumValue(AssistantMode.values, json['mode'], 'mode'),
        messages: ModelJson.objectList(
          json,
          'messages',
          AssistantMessage.fromJson,
        ),
        createdAt: ModelJson.requiredDateTime(json, 'createdAt'),
        updatedAt: ModelJson.requiredDateTime(json, 'updatedAt'),
        isFavorite: ModelJson.optionalBool(json, 'isFavorite') ?? false,
      );

  ModelJsonMap toJson() => {
    'id': id,
    'title': title,
    'mode': mode.name,
    'messages': messages.map((message) => message.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isFavorite': isFavorite,
  };
}
