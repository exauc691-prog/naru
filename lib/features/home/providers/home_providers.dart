import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/enums/learning_activity_type.dart';
import '../../../shared/models/lesson_model.dart';
import '../../../shared/models/learning_path_model.dart';
import '../../../shared/models/module_model.dart';
import '../../learning/providers/learning_providers.dart';
import '../../../shared/models/notification_model.dart';

export '../../../app/providers/app_providers.dart'
    show
        dailyGoalProvider,
        overallProgressProvider,
        recentActivitiesProvider,
        recommendedCoursesProvider,
        userProfileProvider;

class ContinueLearningItem {
  const ContinueLearningItem({required this.course, this.module, this.lesson});

  final CourseModel course;
  final ModuleModel? module;
  final LessonModel? lesson;

  double get progress => course.lessonsCount <= 0
      ? 0
      : (course.completedLessons / course.lessonsCount)
            .clamp(0.0, 1.0)
            .toDouble();
}

final continueLearningProvider = FutureProvider<ContinueLearningItem?>((
  ref,
) async {
  final activities = await ref.watch(recentActivitiesProvider.future);
  final courses = await ref.watch(coursesProvider.future);
  final learningPaths = await ref.watch(learningPathsProvider.future);
  final repository = ref.watch(learningRepositoryProvider);

  for (final activity in activities) {
    String? courseId;

    if (activity.activityType == LearningActivityType.lessonCompleted) {
      final relatedId = activity.relatedId;
      if (relatedId == null) continue;
      final completedLesson = await repository.getLessonById(relatedId);
      courseId = completedLesson?.courseId;
    } else if (activity.activityType == LearningActivityType.courseStarted) {
      courseId = activity.relatedId;
    } else {
      continue;
    }

    if (courseId == null) continue;
    CourseModel? course;
    for (final candidate in courses) {
      if (candidate.id == courseId) {
        course = candidate;
        break;
      }
    }
    if (course == null) continue;

    LearningPathModel? path;
    for (final candidate in learningPaths) {
      if (candidate.courseIds.contains(courseId)) {
        path = candidate;
        break;
      }
    }
    if (path == null) return ContinueLearningItem(course: course);

    final modules = (await repository.getModulesForPath(path.id)).toList()
      ..sort((first, second) => first.order.compareTo(second.order));
    for (final module in modules) {
      final lessons = await repository.getLessonsForModule(module.id);
      for (final lesson in lessons) {
        if (lesson.courseId == course.id && !lesson.isCompleted) {
          return ContinueLearningItem(
            course: course,
            module: module,
            lesson: lesson,
          );
        }
      }
    }

    if (course.lessonsCount <= 0 ||
        course.completedLessons < course.lessonsCount) {
      return ContinueLearningItem(course: course);
    }
  }

  return null;
});

final dashboardNotificationsProvider =
    AsyncNotifierProvider<DashboardNotificationsNotifier,
        List<NotificationModel>>(DashboardNotificationsNotifier.new);

class DashboardNotificationsNotifier
    extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() =>
      ref.read(notificationsProvider.future);

  Future<void> markAllAsRead() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final notification in current)
        NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          createdAt: notification.createdAt,
          isRead: true,
        ),
    ]);
  }

  Future<void> markAsRead(String id) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final notification in current)
        notification.id == id
            ? NotificationModel(
                id: notification.id,
                title: notification.title,
                message: notification.message,
                type: notification.type,
                createdAt: notification.createdAt,
                isRead: true,
              )
            : notification,
    ]);
  }
}
