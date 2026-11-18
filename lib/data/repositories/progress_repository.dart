import '../../shared/models/achievement_model.dart';
import '../../shared/models/daily_goal_model.dart';
import '../../shared/models/learning_activity_model.dart';
import '../../shared/models/progress_model.dart';
import '../../shared/models/skill_progress_model.dart';

abstract interface class ProgressRepository {
  Future<ProgressModel> getOverallProgress();

  /// Returns a percentage from 0 to 100, or null if the course is unknown.
  Future<double?> getCourseProgress(String courseId);

  Future<List<SkillProgressModel>> getSkillProgress();

  Future<List<DailyGoalModel>> getDailyGoals();

  Future<List<LearningActivityModel>> getRecentActivities({int limit = 10});

  Future<List<AchievementModel>> getUnlockedAchievements();

  /// Updates the in-memory progress snapshot only.
  Future<void> saveProgress(ProgressModel progress);

  /// Replaces a goal in memory; returns null if the goal ID is unknown.
  Future<DailyGoalModel?> updateDailyGoal(DailyGoalModel goal);
}
