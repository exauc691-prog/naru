import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/course_model.dart';
import '../../shared/models/daily_goal_model.dart';
import '../../shared/models/learning_activity_model.dart';
import '../../shared/models/notification_model.dart';
import '../../shared/models/progress_model.dart';
import '../../shared/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'repository_providers.dart';

export 'repository_providers.dart';

final userProfileProvider = FutureProvider<UserModel?>(
  (ref) => ref.watch(userRepositoryProvider).getProfile(),
);

final userPreferencesProvider = FutureProvider<UserPreferences?>(
  (ref) => ref.watch(userRepositoryProvider).getPreferences(),
);

final dailyGoalProvider = FutureProvider<DailyGoalModel?>(
  (ref) => ref.watch(userRepositoryProvider).getDailyGoal(),
);

final notificationsProvider = FutureProvider<List<NotificationModel>>(
  (ref) => ref.watch(userRepositoryProvider).getNotifications(),
);

final recommendedCoursesProvider = FutureProvider<List<CourseModel>>(
  (ref) => ref.watch(learningRepositoryProvider).getRecommendedCourses(),
);

final overallProgressProvider = FutureProvider<ProgressModel>(
  (ref) => ref.watch(progressRepositoryProvider).getOverallProgress(),
);

final recentActivitiesProvider = FutureProvider<List<LearningActivityModel>>(
  (ref) => ref.watch(progressRepositoryProvider).getRecentActivities(),
);
