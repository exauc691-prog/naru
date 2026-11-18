import 'enums/difficulty_level.dart';
import 'enums/course_format.dart';
import 'model_json.dart';

class CourseModel {
  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.domainId,
    required this.instructorName,
    this.thumbnailUrl,
    required this.difficulty,
    required this.estimatedDuration,
    required this.lessonsCount,
    required this.completedLessons,
    required this.rating,
    required List<String> tags,
    required this.isRecommended,
    this.isNew = false,
    this.isPremium = false,
    this.format = CourseFormat.mixed,
    this.enrolledStudents = 0,
    this.publishedAt,
    List<String> prerequisites = const [],
  }) : tags = List.unmodifiable(tags),
       prerequisites = List.unmodifiable(prerequisites);

  final String id;
  final String title;
  final String description;
  final String domainId;
  final String instructorName;
  final String? thumbnailUrl;
  final DifficultyLevel difficulty;

  /// Stored in JSON as an integer number of minutes.
  final Duration estimatedDuration;

  final int lessonsCount;
  final int completedLessons;
  final double rating;
  final List<String> tags;
  final bool isRecommended;
  final bool isNew;
  final bool isPremium;
  final CourseFormat format;
  final int enrolledStudents;
  final DateTime? publishedAt;
  final List<String> prerequisites;

  factory CourseModel.fromJson(ModelJsonMap json) => CourseModel(
    id: ModelJson.requiredString(json, 'id'),
    title: ModelJson.requiredString(json, 'title'),
    description: ModelJson.requiredString(json, 'description'),
    domainId: ModelJson.requiredString(json, 'domainId'),
    instructorName: ModelJson.requiredString(json, 'instructorName'),
    thumbnailUrl: ModelJson.optionalString(json, 'thumbnailUrl'),
    difficulty: ModelJson.enumValue(
      DifficultyLevel.values,
      json['difficulty'],
      'difficulty',
    ),
    estimatedDuration: ModelJson.requiredDuration(json, 'estimatedDuration'),
    lessonsCount: ModelJson.requiredInt(json, 'lessonsCount'),
    completedLessons: ModelJson.requiredInt(json, 'completedLessons'),
    rating: ModelJson.requiredDouble(json, 'rating'),
    tags: ModelJson.stringList(json, 'tags'),
    isRecommended: ModelJson.requiredBool(json, 'isRecommended'),
    isNew: ModelJson.optionalBool(json, 'isNew') ?? false,
    isPremium: ModelJson.optionalBool(json, 'isPremium') ?? false,
    format: json['format'] == null
        ? CourseFormat.mixed
        : ModelJson.enumValue(CourseFormat.values, json['format'], 'format'),
    enrolledStudents: ModelJson.optionalInt(json, 'enrolledStudents') ?? 0,
    publishedAt: ModelJson.optionalDateTime(json, 'publishedAt'),
    prerequisites: ModelJson.optionalStringList(json, 'prerequisites'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'domainId': domainId,
    'instructorName': instructorName,
    'thumbnailUrl': thumbnailUrl,
    'difficulty': difficulty.name,
    'estimatedDuration': estimatedDuration.inMinutes,
    'lessonsCount': lessonsCount,
    'completedLessons': completedLessons,
    'rating': rating,
    'tags': tags,
    'isRecommended': isRecommended,
    'isNew': isNew,
    'isPremium': isPremium,
    'format': format.name,
    'enrolledStudents': enrolledStudents,
    'publishedAt': publishedAt?.toIso8601String(),
    'prerequisites': prerequisites,
  };
}
