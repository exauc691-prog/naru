import 'model_json.dart';

class ProgressModel {
  const ProgressModel({
    required this.userId,
    required this.totalLearningMinutes,
    required this.completedCourses,
    required this.completedLessons,
    required this.completedExercises,
    required this.currentStreak,
    required this.longestStreak,
    required this.overallProgress,
    required this.lastActivityAt,
  });

  final String userId;
  final int totalLearningMinutes;
  final int completedCourses;
  final int completedLessons;
  final int completedExercises;
  final int currentStreak;
  final int longestStreak;

  /// Overall progress from 0 to 100.
  final double overallProgress;

  final DateTime? lastActivityAt;

  factory ProgressModel.fromJson(ModelJsonMap json) => ProgressModel(
    userId: ModelJson.requiredString(json, 'userId'),
    totalLearningMinutes: ModelJson.requiredInt(json, 'totalLearningMinutes'),
    completedCourses: ModelJson.requiredInt(json, 'completedCourses'),
    completedLessons: ModelJson.requiredInt(json, 'completedLessons'),
    completedExercises: ModelJson.requiredInt(json, 'completedExercises'),
    currentStreak: ModelJson.requiredInt(json, 'currentStreak'),
    longestStreak: ModelJson.requiredInt(json, 'longestStreak'),
    overallProgress: ModelJson.requiredDouble(json, 'overallProgress'),
    lastActivityAt: ModelJson.optionalDateTime(json, 'lastActivityAt'),
  );

  ModelJsonMap toJson() => {
    'userId': userId,
    'totalLearningMinutes': totalLearningMinutes,
    'completedCourses': completedCourses,
    'completedLessons': completedLessons,
    'completedExercises': completedExercises,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'overallProgress': overallProgress,
    'lastActivityAt': lastActivityAt?.toIso8601String(),
  };
}
