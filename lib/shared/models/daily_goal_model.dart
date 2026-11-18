import 'model_json.dart';

class DailyGoalModel {
  const DailyGoalModel({
    required this.id,
    required this.targetMinutes,
    required this.completedMinutes,
    required this.targetLessons,
    required this.completedLessons,
    required this.date,
    required this.isCompleted,
  });

  final String id;
  final int targetMinutes;
  final int completedMinutes;
  final int targetLessons;
  final int completedLessons;
  final DateTime date;
  final bool isCompleted;

  factory DailyGoalModel.fromJson(ModelJsonMap json) => DailyGoalModel(
    id: ModelJson.requiredString(json, 'id'),
    targetMinutes: ModelJson.requiredInt(json, 'targetMinutes'),
    completedMinutes: ModelJson.requiredInt(json, 'completedMinutes'),
    targetLessons: ModelJson.requiredInt(json, 'targetLessons'),
    completedLessons: ModelJson.requiredInt(json, 'completedLessons'),
    date: ModelJson.requiredDateTime(json, 'date'),
    isCompleted: ModelJson.requiredBool(json, 'isCompleted'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'targetMinutes': targetMinutes,
    'completedMinutes': completedMinutes,
    'targetLessons': targetLessons,
    'completedLessons': completedLessons,
    'date': date.toIso8601String(),
    'isCompleted': isCompleted,
  };
}
