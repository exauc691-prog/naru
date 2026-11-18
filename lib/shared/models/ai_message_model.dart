import 'enums/ai_message_sender.dart';
import 'enums/ai_message_type.dart';
import 'model_json.dart';

class AIMessageModel {
  const AIMessageModel({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.createdAt,
    required this.messageType,
  });

  final String id;
  final String conversationId;
  final String content;
  final AIMessageSender sender;
  final DateTime createdAt;
  final AIMessageType messageType;

  factory AIMessageModel.fromJson(ModelJsonMap json) => AIMessageModel(
    id: ModelJson.requiredString(json, 'id'),
    conversationId: ModelJson.requiredString(json, 'conversationId'),
    content: ModelJson.requiredString(json, 'content'),
    sender: ModelJson.enumValue(
      AIMessageSender.values,
      json['sender'],
      'sender',
    ),
    createdAt: ModelJson.requiredDateTime(json, 'createdAt'),
    messageType: ModelJson.enumValue(
      AIMessageType.values,
      json['messageType'],
      'messageType',
    ),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'conversationId': conversationId,
    'content': content,
    'sender': sender.name,
    'createdAt': createdAt.toIso8601String(),
    'messageType': messageType.name,
  };
}
