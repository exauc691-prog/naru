import '../../shared/mock/mock_data.dart';
import '../../shared/models/achievement_model.dart';
import '../../shared/models/course_model.dart';
import '../../shared/models/daily_goal_model.dart';
import '../../shared/models/learning_activity_model.dart';
import '../../shared/models/progress_model.dart';
import '../../shared/models/skill_progress_model.dart';
import '../repositories/progress_repository.dart';

class MockProgressRepository implements ProgressRepository {
  MockProgressRepository({
    ProgressModel? initialProgress,
    Iterable<CourseModel>? courses,
    Iterable<SkillProgressModel>? skillProgress,
    Iterable<DailyGoalModel>? dailyGoals,
    Iterable<LearningActivityModel>? activities,
    Iterable<AchievementModel>? achievements,
  }) : _progress = initialProgress ?? mockProgress,
       _courses = List.unmodifiable(courses ?? mockCourses),
       _skillProgress = List.unmodifiable(skillProgress ?? mockSkillProgress),
       _dailyGoals = List.of(dailyGoals ?? mockDailyGoals),
       _activities = List.unmodifiable(activities ?? mockLearningActivities),
       _achievements = List.unmodifiable(achievements ?? mockAchievements);

  ProgressModel _progress;
  final List<CourseModel> _courses;
  final List<SkillProgressModel> _skillProgress;
  final List<DailyGoalModel> _dailyGoals;
  final List<LearningActivityModel> _activities;
  final List<AchievementModel> _achievements;

  @override
  Future<ProgressModel> getOverallProgress() async => _progress;

  @override
  Future<double?> getCourseProgress(String courseId) async {
    for (final course in _courses) {
      if (course.id == courseId) {
        if (course.lessonsCount <= 0) return 0;
        return course.completedLessons / course.lessonsCount * 100;
      }
    }
    return null;
  }

  @override
  Future<List<SkillProgressModel>> getSkillProgress() async => _skillProgress;

  @override
  Future<List<DailyGoalModel>> getDailyGoals() async =>
      List.unmodifiable(_dailyGoals);

  @override
  Future<List<LearningActivityModel>> getRecentActivities({
    int limit = 10,
  }) async {
    if (limit <= 0) return const [];

    final activities = List<LearningActivityModel>.of(_activities)
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return List.unmodifiable(activities.take(limit));
  }

  @override
  Future<List<AchievementModel>> getUnlockedAchievements() async =>
      List.unmodifiable(
        _achievements.where((achievement) => achievement.isUnlocked),
      );

  @override
  Future<void> saveProgress(ProgressModel progress) async {
    if (progress.userId != _progress.userId) {
      throw ArgumentError.value(
        progress.userId,
        'progress.userId',
        'Progress must belong to the current mock user.',
      );
    }
    _progress = progress;
  }

  @override
  Future<DailyGoalModel?> updateDailyGoal(DailyGoalModel goal) async {
    final goalIndex = _dailyGoals.indexWhere(
      (currentGoal) => currentGoal.id == goal.id,
    );
    if (goalIndex == -1) return null;

    _dailyGoals[goalIndex] = goal;
    return goal;
  }
}
