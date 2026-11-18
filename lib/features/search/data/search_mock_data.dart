import '../../../app/router/app_routes.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/enums/difficulty_level.dart';
import '../../../shared/models/exercise_model.dart';
import '../../../shared/models/lesson_model.dart';
import '../../library/models/library_resource.dart';
import '../models/search_models.dart';

const popularSearches = <String>[
  'Python',
  'Flutter',
  'IA',
  'développement web',
  'mathématiques',
  'entrepreneuriat',
];

List<SearchResult> buildSearchCatalog({
  required List<CourseModel> courses,
  required List<LessonModel> lessons,
  required List<ExerciseModel> exercises,
  required List<LibraryResource> resources,
}) {
  final results = <SearchResult>[
    for (final course in courses)
      SearchResult(
        id: 'course-${course.id}',
        title: course.title,
        description: course.description,
        type: SearchResultType.course,
        category: course.domainId,
        level: _level(course.difficulty),
        durationMinutes: course.estimatedDuration.inMinutes,
        route: AppRoutes.courseDetailsPath(course.id),
        keywords: course.tags,
        progress: course.lessonsCount == 0
            ? null
            : course.completedLessons / course.lessonsCount,
        accessLabel: course.isPremium ? 'Premium' : 'Gratuit',
        publishedAt: course.publishedAt,
        popularity: course.enrolledStudents,
      ),
    for (final lesson in lessons)
      SearchResult(
        id: 'lesson-${lesson.id}',
        title: lesson.title,
        description: lesson.description,
        type: SearchResultType.lesson,
        category: 'Cours',
        level: _level(lesson.difficulty),
        durationMinutes: lesson.estimatedDuration.inMinutes,
        route: AppRoutes.lessonDetailsPath(lesson.id),
        keywords: lesson.objectives,
        progress: lesson.isCompleted ? 1 : null,
      ),
    for (final exercise in exercises)
      SearchResult(
        id: 'exercise-${exercise.id}',
        title: exercise.title,
        description: exercise.question,
        type: SearchResultType.exercise,
        category: 'Exercice',
        level: _level(exercise.difficulty),
        durationMinutes: 10,
        route: AppRoutes.exerciseDetailsPath(exercise.id),
        keywords: [exercise.exerciseType.name, exercise.explanation],
      ),
    for (final resource in resources)
      SearchResult(
        id: 'resource-${resource.id}',
        title: resource.title,
        description: resource.description,
        type: resource.type == LibraryResourceType.book
            ? SearchResultType.book
            : SearchResultType.document,
        category: resource.categoryId,
        level: _levelName(resource.difficulty),
        durationMinutes: (resource.pages ?? 20) * 2,
        route: AppRoutes.libraryResourcePath(resource.id),
        keywords: resource.topics,
        accessLabel: resource.availability.label,
        priceLabel: resource.individualPriceInCents == null
            ? null
            : '${(resource.individualPriceInCents! / 100).toStringAsFixed(2)} \$',
        publishedAt: resource.publishedAt,
        popularity: resource.popularity,
      ),
  ];
  return List.unmodifiable(results);
}

SearchLevel _level(DifficultyLevel level) => switch (level) {
  DifficultyLevel.beginner => SearchLevel.beginner,
  DifficultyLevel.intermediate => SearchLevel.intermediate,
  DifficultyLevel.advanced => SearchLevel.advanced,
};

SearchLevel _levelName(String? level) {
  final normalized = level?.toLowerCase() ?? '';
  if (normalized.contains('interm')) return SearchLevel.intermediate;
  if (normalized.contains('avan')) return SearchLevel.advanced;
  return SearchLevel.beginner;
}
