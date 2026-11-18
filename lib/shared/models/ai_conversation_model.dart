import 'ai_message_model.dart';
import 'model_json.dart';

class AIConversationModel {
  AIConversationModel({
    required this.id,
    required this.title,
    required List<AIMessageModel> messages,
    required this.createdAt,
    required this.updatedAt,
  }) : messages = List.unmodifiable(messages);

  final String id;
  final String title;
  final List<AIMessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AIConversationModel.fromJson(ModelJsonMap json) =>
      AIConversationModel(
        id: ModelJson.requiredString(json, 'id'),
        title: ModelJson.requiredString(json, 'title'),
        messages: ModelJson.objectList(
          json,
          'messages',
          AIMessageModel.fromJson,
        ),
        createdAt: ModelJson.requiredDateTime(json, 'createdAt'),
        updatedAt: ModelJson.requiredDateTime(json, 'updatedAt'),
      );

  ModelJsonMap toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((message) => message.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
