import 'enums/difficulty_level.dart';
import 'model_json.dart';

class LearningPathModel {
  LearningPathModel({
    required this.id,
    required this.title,
    required this.description,
    required this.domainId,
    required this.level,
    required this.estimatedDuration,
    required List<String> courseIds,
    List<String> moduleIds = const [],
    required this.progressPercentage,
    required this.isCompleted,
  }) : courseIds = List.unmodifiable(courseIds),
       moduleIds = List.unmodifiable(moduleIds);

  final String id;
  final String title;
  final String description;
  final String domainId;
  final DifficultyLevel level;

  /// Stored in JSON as an integer number of minutes.
  final Duration estimatedDuration;

  final List<String> courseIds;
  final List<String> moduleIds;

  /// Progress from 0 to 100.
  final double progressPercentage;

  final bool isCompleted;

  factory LearningPathModel.fromJson(ModelJsonMap json) => LearningPathModel(
    id: ModelJson.requiredString(json, 'id'),
    title: ModelJson.requiredString(json, 'title'),
    description: ModelJson.requiredString(json, 'description'),
    domainId: ModelJson.requiredString(json, 'domainId'),
    level: ModelJson.enumValue(DifficultyLevel.values, json['level'], 'level'),
    estimatedDuration: ModelJson.requiredDuration(json, 'estimatedDuration'),
    courseIds: ModelJson.stringList(json, 'courseIds'),
    moduleIds: ModelJson.optionalStringList(json, 'moduleIds'),
    progressPercentage: ModelJson.requiredDouble(json, 'progressPercentage'),
    isCompleted: ModelJson.requiredBool(json, 'isCompleted'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'domainId': domainId,
    'level': level.name,
    'estimatedDuration': estimatedDuration.inMinutes,
    'courseIds': courseIds,
    'moduleIds': moduleIds,
    'progressPercentage': progressPercentage,
    'isCompleted': isCompleted,
  };
}
