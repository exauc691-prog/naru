import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart'
    show recentActivitiesProvider;
import '../../../app/providers/repository_providers.dart';
import '../../../data/repositories/learning_repository.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/enums/learning_activity_type.dart';
import '../../../shared/models/learning_domain_model.dart';
import '../../../shared/models/learning_path_model.dart';
import '../../../shared/models/lesson_model.dart';
import '../../../shared/models/module_model.dart';

export '../../../app/providers/app_providers.dart'
    show recommendedCoursesProvider;

final learningDomainsProvider = FutureProvider<List<LearningDomainModel>>(
  (ref) => ref.watch(learningRepositoryProvider).getDomains(),
);

final coursesProvider = FutureProvider<List<CourseModel>>(
  (ref) => ref.watch(learningRepositoryProvider).getCourses(),
);

final inProgressCoursesProvider = FutureProvider<List<CourseModel>>((
  ref,
) async {
  final courses = await ref.watch(coursesProvider.future);
  final activities = await ref.watch(recentActivitiesProvider.future);
  final startedCourseIds = activities
      .where(
        (activity) =>
            activity.activityType == LearningActivityType.courseStarted,
      )
      .map((activity) => activity.relatedId)
      .whereType<String>()
      .toSet();

  return List.unmodifiable(
    courses.where(
      (course) =>
          course.lessonsCount > 0 &&
          course.completedLessons < course.lessonsCount &&
          (course.completedLessons > 0 || startedCourseIds.contains(course.id)),
    ),
  );
});

final newCoursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  final courses = await ref.watch(coursesProvider.future);
  return List.unmodifiable(courses.where((course) => course.isNew));
});

final courseByIdProvider = FutureProvider.family<CourseModel?, String>((
  ref,
  courseId,
) {
  return ref.watch(learningRepositoryProvider).getCourseById(courseId);
});

final coursesByDomainProvider =
    FutureProvider.family<List<CourseModel>, String>((ref, domainId) {
      return ref.watch(learningRepositoryProvider).getCoursesByDomain(domainId);
    });

final courseSearchProvider = FutureProvider.family<List<CourseModel>, String>((
  ref,
  query,
) {
  return ref.watch(learningRepositoryProvider).searchCourses(query);
});

final learningPathsProvider = FutureProvider<List<LearningPathModel>>(
  (ref) => ref.watch(learningRepositoryProvider).getLearningPaths(),
);

final learningPathByIdProvider =
    FutureProvider.family<LearningPathModel?, String>((ref, pathId) {
      return ref.watch(learningRepositoryProvider).getLearningPathById(pathId);
    });

final modulesForPathProvider = FutureProvider.family<List<ModuleModel>, String>(
  (ref, pathId) {
    return ref.watch(learningRepositoryProvider).getModulesForPath(pathId);
  },
);

final lessonsForModuleProvider =
    FutureProvider.family<List<LessonModel>, String>((ref, moduleId) {
      return ref
          .watch(learningRepositoryProvider)
          .getLessonsForModule(moduleId);
    });

final lessonByIdProvider = FutureProvider.family<LessonModel?, String>((
  ref,
  lessonId,
) {
  return ref.watch(learningRepositoryProvider).getLessonById(lessonId);
});

class LearningModuleContent {
  const LearningModuleContent({required this.module, required this.lessons});

  final ModuleModel module;
  final List<LessonModel> lessons;
}

class CoursePageData {
  const CoursePageData({
    required this.course,
    required this.domain,
    required this.curriculum,
  });

  final CourseModel course;
  final LearningDomainModel? domain;
  final List<LearningModuleContent> curriculum;
}

class LearningPathPageData {
  const LearningPathPageData({
    required this.path,
    required this.domain,
    required this.courses,
    required this.curriculum,
  });

  final LearningPathModel path;
  final LearningDomainModel? domain;
  final List<CourseModel> courses;
  final List<LearningModuleContent> curriculum;
}

final learningPathCurriculumProvider =
    FutureProvider.family<List<LearningModuleContent>, String>((
      ref,
      pathId,
    ) async {
      final modulesFuture = ref.watch(modulesForPathProvider(pathId).future);
      final repository = ref.watch(learningRepositoryProvider);
      final modules = (await modulesFuture).toList()
        ..sort((first, second) => first.order.compareTo(second.order));
      final curriculum = <LearningModuleContent>[];

      for (final module in modules) {
        final lessons = await repository.getLessonsForModule(module.id);
        curriculum.add(
          LearningModuleContent(
            module: module,
            lessons: List.unmodifiable(lessons),
          ),
        );
      }

      return List.unmodifiable(curriculum);
    });

final coursePageDataProvider = FutureProvider.family<CoursePageData?, String>((
  ref,
  courseId,
) async {
  final courseFuture = ref.watch(courseByIdProvider(courseId).future);
  final domainsFuture = ref.watch(learningDomainsProvider.future);
  final pathsFuture = ref.watch(learningPathsProvider.future);
  final repository = ref.watch(learningRepositoryProvider);

  final course = await courseFuture;
  if (course == null) return null;

  final domains = await domainsFuture;
  final paths = await pathsFuture;
  final matchingPaths = paths
      .where((path) => path.courseIds.contains(course.id))
      .toList();
  final curriculum = await _loadCurriculum(
    repository,
    matchingPaths,
    courseId: course.id,
  );

  return CoursePageData(
    course: course,
    domain: _domainFor(domains, course.domainId),
    curriculum: curriculum,
  );
});

final learningPathPageDataProvider =
    FutureProvider.family<LearningPathPageData?, String>((ref, pathId) async {
      final pathFuture = ref.watch(learningPathByIdProvider(pathId).future);
      final domainsFuture = ref.watch(learningDomainsProvider.future);
      final coursesFuture = ref.watch(coursesProvider.future);
      final curriculumFuture = ref.watch(
        learningPathCurriculumProvider(pathId).future,
      );

      final path = await pathFuture;
      if (path == null) return null;

      final domains = await domainsFuture;
      final courses = await coursesFuture;
      final curriculum = await curriculumFuture;
      final courseIds = path.courseIds.toSet();

      return LearningPathPageData(
        path: path,
        domain: _domainFor(domains, path.domainId),
        courses: List.unmodifiable(
          courses.where((course) => courseIds.contains(course.id)),
        ),
        curriculum: curriculum,
      );
    });

LearningDomainModel? _domainFor(
  List<LearningDomainModel> domains,
  String domainId,
) {
  for (final domain in domains) {
    if (domain.id == domainId) return domain;
  }
  return null;
}

Future<List<LearningModuleContent>> _loadCurriculum(
  LearningRepository repository,
  List<LearningPathModel> paths, {
  required String courseId,
}) async {
  final curriculum = <LearningModuleContent>[];

  for (final path in paths) {
    final modules = (await repository.getModulesForPath(path.id)).toList()
      ..sort((first, second) => first.order.compareTo(second.order));

    for (final module in modules) {
      final lessons = await repository.getLessonsForModule(module.id);
      final courseLessons = lessons
          .where((lesson) => lesson.courseId == courseId)
          .toList();
      if (courseLessons.isEmpty) continue;

      curriculum.add(
        LearningModuleContent(
          module: module,
          lessons: List.unmodifiable(courseLessons),
        ),
      );
    }
  }

  return List.unmodifiable(curriculum);
}
