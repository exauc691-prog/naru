import '../../shared/models/course_model.dart';
import '../../shared/models/learning_domain_model.dart';
import '../../shared/models/learning_path_model.dart';
import '../../shared/models/lesson_model.dart';
import '../../shared/models/module_model.dart';

abstract interface class LearningRepository {
  Future<List<LearningDomainModel>> getDomains();

  Future<List<CourseModel>> getCourses();

  Future<CourseModel?> getCourseById(String courseId);

  Future<List<CourseModel>> searchCourses(String query);

  Future<List<CourseModel>> getCoursesByDomain(String domainId);

  Future<List<LearningPathModel>> getLearningPaths();

  Future<LearningPathModel?> getLearningPathById(String pathId);

  Future<List<ModuleModel>> getModulesForPath(String pathId);

  Future<List<LessonModel>> getLessonsForModule(String moduleId);

  Future<LessonModel?> getLessonById(String lessonId);

  Future<List<CourseModel>> getRecommendedCourses();
}
