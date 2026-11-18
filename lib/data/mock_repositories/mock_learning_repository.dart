import '../../shared/mock/mock_data.dart';
import '../../shared/models/course_model.dart';
import '../../shared/models/learning_domain_model.dart';
import '../../shared/models/learning_path_model.dart';
import '../../shared/models/lesson_model.dart';
import '../../shared/models/module_model.dart';
import '../repositories/learning_repository.dart';

class MockLearningRepository implements LearningRepository {
  MockLearningRepository({
    Iterable<LearningDomainModel>? domains,
    Iterable<CourseModel>? courses,
    Iterable<LearningPathModel>? learningPaths,
    Iterable<ModuleModel>? modules,
    Iterable<LessonModel>? lessons,
  }) : _domains = List.unmodifiable(domains ?? mockDomains),
       _courses = List.unmodifiable(courses ?? mockCourses),
       _learningPaths = List.unmodifiable(learningPaths ?? mockLearningPaths),
       _modules = List.unmodifiable(modules ?? mockModules),
       _lessons = List.unmodifiable(lessons ?? mockLessons);

  final List<LearningDomainModel> _domains;
  final List<CourseModel> _courses;
  final List<LearningPathModel> _learningPaths;
  final List<ModuleModel> _modules;
  final List<LessonModel> _lessons;

  @override
  Future<List<LearningDomainModel>> getDomains() async => _domains;

  @override
  Future<List<CourseModel>> getCourses() async => _courses;

  @override
  Future<CourseModel?> getCourseById(String courseId) async {
    for (final course in _courses) {
      if (course.id == courseId) return course;
    }
    return null;
  }

  @override
  Future<List<CourseModel>> searchCourses(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return const [];

    final domainNames = {
      for (final domain in _domains) domain.id: domain.name.toLowerCase(),
    };

    return List.unmodifiable(
      _courses.where((course) {
        return course.title.toLowerCase().contains(normalizedQuery) ||
            course.description.toLowerCase().contains(normalizedQuery) ||
            course.instructorName.toLowerCase().contains(normalizedQuery) ||
            (domainNames[course.domainId]?.contains(normalizedQuery) ??
                false) ||
            course.tags.any(
              (tag) => tag.toLowerCase().contains(normalizedQuery),
            );
      }),
    );
  }

  @override
  Future<List<CourseModel>> getCoursesByDomain(String domainId) async =>
      List.unmodifiable(
        _courses.where((course) => course.domainId == domainId),
      );

  @override
  Future<List<LearningPathModel>> getLearningPaths() async => _learningPaths;

  @override
  Future<LearningPathModel?> getLearningPathById(String pathId) async {
    for (final path in _learningPaths) {
      if (path.id == pathId) return path;
    }
    return null;
  }

  @override
  Future<List<ModuleModel>> getModulesForPath(String pathId) async =>
      List.unmodifiable(
        _modules.where((module) => module.learningPathId == pathId),
      );

  @override
  Future<List<LessonModel>> getLessonsForModule(String moduleId) async {
    ModuleModel? requestedModule;
    for (final module in _modules) {
      if (module.id == moduleId) {
        requestedModule = module;
        break;
      }
    }
    if (requestedModule == null) return const [];

    final lessonIds = requestedModule.lessonIds.toSet();
    final lessons =
        _lessons
            .where(
              (lesson) =>
                  lesson.moduleId == moduleId && lessonIds.contains(lesson.id),
            )
            .toList()
          ..sort((first, second) => first.order.compareTo(second.order));
    return List.unmodifiable(lessons);
  }

  @override
  Future<LessonModel?> getLessonById(String lessonId) async {
    for (final lesson in _lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  @override
  Future<List<CourseModel>> getRecommendedCourses() async =>
      List.unmodifiable(_courses.where((course) => course.isRecommended));
}
