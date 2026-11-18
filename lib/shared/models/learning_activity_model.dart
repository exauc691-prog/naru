import 'enums/learning_activity_type.dart';
import 'model_json.dart';

class LearningActivityModel {
  const LearningActivityModel({
    required this.id,
    required this.activityType,
    required this.title,
    required this.description,
    this.relatedId,
    required this.createdAt,
    this.durationMinutes,
  });

  final String id;
  final LearningActivityType activityType;
  final String title;
  final String description;
  final String? relatedId;
  final DateTime createdAt;
  final int? durationMinutes;

  factory LearningActivityModel.fromJson(ModelJsonMap json) =>
      LearningActivityModel(
        id: ModelJson.requiredString(json, 'id'),
        activityType: ModelJson.enumValue(
          LearningActivityType.values,
          json['activityType'],
          'activityType',
        ),
        title: ModelJson.requiredString(json, 'title'),
        description: ModelJson.requiredString(json, 'description'),
        relatedId: ModelJson.optionalString(json, 'relatedId'),
        createdAt: ModelJson.requiredDateTime(json, 'createdAt'),
        durationMinutes: ModelJson.optionalInt(json, 'durationMinutes'),
      );

  ModelJsonMap toJson() => {
    'id': id,
    'activityType': activityType.name,
    'title': title,
    'description': description,
    'relatedId': relatedId,
    'createdAt': createdAt.toIso8601String(),
    'durationMinutes': durationMinutes,
  };
}
