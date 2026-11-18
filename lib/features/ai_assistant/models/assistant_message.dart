import '../../../shared/models/model_json.dart';

enum AssistantMessageSender { user, assistant }

enum AssistantMessageFeedback { helpful, notHelpful }

class AssistantMessage {
  const AssistantMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.createdAt,
    this.feedback,
  });

  final String id;
  final String content;
  final AssistantMessageSender sender;
  final DateTime createdAt;
  final AssistantMessageFeedback? feedback;

  AssistantMessage copyWith({
    String? content,
    AssistantMessageFeedback? feedback,
    bool clearFeedback = false,
  }) => AssistantMessage(
    id: id,
    content: content ?? this.content,
    sender: sender,
    createdAt: createdAt,
    feedback: clearFeedback ? null : feedback ?? this.feedback,
  );

  factory AssistantMessage.fromJson(ModelJsonMap json) => AssistantMessage(
    id: ModelJson.requiredString(json, 'id'),
    content: ModelJson.requiredString(json, 'content'),
    sender: ModelJson.enumValue(
      AssistantMessageSender.values,
      json['sender'],
      'sender',
    ),
    createdAt: ModelJson.requiredDateTime(json, 'createdAt'),
    feedback: json['feedback'] == null
        ? null
        : ModelJson.enumValue(
            AssistantMessageFeedback.values,
            json['feedback'],
            'feedback',
          ),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'content': content,
    'sender': sender.name,
    'createdAt': createdAt.toIso8601String(),
    'feedback': feedback?.name,
  };
}
