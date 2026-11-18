import '../../shared/models/daily_goal_model.dart';
import '../../shared/models/enums/difficulty_level.dart';
import '../../shared/models/notification_model.dart';
import '../../shared/models/user_model.dart';

abstract interface class UserRepository {
  Future<UserModel?> getProfile();

  Future<void> updateProfile(UserModel profile);

  Future<UserPreferences?> getPreferences();

  Future<DailyGoalModel?> getDailyGoal();

  Future<List<NotificationModel>> getNotifications();
}

class UserPreferences {
  UserPreferences({
    required List<String> selectedDomains,
    required this.currentLevel,
    required List<String> learningGoals,
    required this.dailyLearningMinutes,
  }) : selectedDomains = List.unmodifiable(selectedDomains),
       learningGoals = List.unmodifiable(learningGoals);

  final List<String> selectedDomains;
  final DifficultyLevel currentLevel;
  final List<String> learningGoals;
  final int dailyLearningMinutes;
}
