import '../../shared/mock/mock_data.dart';
import '../../shared/models/daily_goal_model.dart';
import '../../shared/models/notification_model.dart';
import '../../shared/models/user_model.dart';
import '../repositories/user_repository.dart';

class MockUserRepository implements UserRepository {
  MockUserRepository({
    UserModel? initialProfile,
    Iterable<DailyGoalModel>? dailyGoals,
    Iterable<NotificationModel>? notifications,
  }) : _profile = initialProfile ?? mockUser,
       _dailyGoals = List.unmodifiable(dailyGoals ?? mockDailyGoals),
       _notifications = List.unmodifiable(notifications ?? mockNotifications);

  UserModel? _profile;
  final List<DailyGoalModel> _dailyGoals;
  final List<NotificationModel> _notifications;

  @override
  Future<UserModel?> getProfile() async => _profile;

  @override
  Future<void> updateProfile(UserModel profile) async {
    _profile = profile;
  }

  @override
  Future<UserPreferences?> getPreferences() async {
    final profile = _profile;
    if (profile == null) return null;

    return UserPreferences(
      selectedDomains: profile.selectedDomains,
      currentLevel: profile.currentLevel,
      learningGoals: profile.learningGoals,
      dailyLearningMinutes: profile.dailyLearningMinutes,
    );
  }

  @override
  Future<DailyGoalModel?> getDailyGoal() async {
    if (_dailyGoals.isEmpty) return null;
    return _dailyGoals.reduce(
      (latest, goal) => goal.date.isAfter(latest.date) ? goal : latest,
    );
  }

  @override
  Future<List<NotificationModel>> getNotifications() async => _notifications;
}
