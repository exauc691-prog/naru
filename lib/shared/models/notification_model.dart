import 'enums/notification_type.dart';
import 'model_json.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  factory NotificationModel.fromJson(ModelJsonMap json) => NotificationModel(
    id: ModelJson.requiredString(json, 'id'),
    title: ModelJson.requiredString(json, 'title'),
    message: ModelJson.requiredString(json, 'message'),
    type: ModelJson.enumValue(NotificationType.values, json['type'], 'type'),
    createdAt: ModelJson.requiredDateTime(json, 'createdAt'),
    isRead: ModelJson.requiredBool(json, 'isRead'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };
}
