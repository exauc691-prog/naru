import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/providers/repository_providers.dart';
import '../../../shared/models/achievement_model.dart';
import '../../../shared/models/daily_goal_model.dart';
import '../../../shared/models/skill_progress_model.dart';

export '../../../app/providers/app_providers.dart'
    show overallProgressProvider, recentActivitiesProvider;

final courseProgressProvider = FutureProvider.family<double?, String>((
  ref,
  courseId,
) {
  return ref.watch(progressRepositoryProvider).getCourseProgress(courseId);
});

final skillProgressProvider = FutureProvider<List<SkillProgressModel>>(
  (ref) => ref.watch(progressRepositoryProvider).getSkillProgress(),
);

final dailyGoalsProvider = FutureProvider<List<DailyGoalModel>>(
  (ref) => ref.watch(progressRepositoryProvider).getDailyGoals(),
);

final unlockedAchievementsProvider = FutureProvider<List<AchievementModel>>(
  (ref) => ref.watch(progressRepositoryProvider).getUnlockedAchievements(),
);
