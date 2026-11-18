import 'enums/difficulty_level.dart';
import 'model_json.dart';

class SkillProgressModel {
  const SkillProgressModel({
    required this.id,
    required this.skillName,
    required this.domainId,
    required this.progressPercentage,
    required this.completedActivities,
    required this.totalActivities,
    required this.level,
  });

  final String id;
  final String skillName;
  final String domainId;

  /// Skill progress from 0 to 100.
  final double progressPercentage;

  final int completedActivities;
  final int totalActivities;
  final DifficultyLevel level;

  factory SkillProgressModel.fromJson(ModelJsonMap json) => SkillProgressModel(
    id: ModelJson.requiredString(json, 'id'),
    skillName: ModelJson.requiredString(json, 'skillName'),
    domainId: ModelJson.requiredString(json, 'domainId'),
    progressPercentage: ModelJson.requiredDouble(json, 'progressPercentage'),
    completedActivities: ModelJson.requiredInt(json, 'completedActivities'),
    totalActivities: ModelJson.requiredInt(json, 'totalActivities'),
    level: ModelJson.enumValue(DifficultyLevel.values, json['level'], 'level'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'skillName': skillName,
    'domainId': domainId,
    'progressPercentage': progressPercentage,
    'completedActivities': completedActivities,
    'totalActivities': totalActivities,
    'level': level.name,
  };
}
