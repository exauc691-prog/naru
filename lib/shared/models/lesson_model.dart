import 'enums/difficulty_level.dart';
import 'enums/lesson_format.dart';
import 'lesson_content_block.dart';
import 'model_json.dart';

class LessonModel {
  LessonModel({
    required this.id,
    required this.courseId,
    required this.moduleId,
    required this.title,
    required this.description,
    required List<LessonContentBlock> content,
    required List<String> objectives,
    required this.estimatedDuration,
    required this.order,
    required this.difficulty,
    required this.isCompleted,
    this.format = LessonFormat.text,
  }) : content = List.unmodifiable(content),
       objectives = List.unmodifiable(objectives);

  final String id;
  final String courseId;
  final String moduleId;
  final String title;
  final String description;
  final List<LessonContentBlock> content;
  final List<String> objectives;

  /// Stored in JSON as an integer number of minutes.
  final Duration estimatedDuration;

  final int order;
  final DifficultyLevel difficulty;
  final bool isCompleted;
  final LessonFormat format;

  factory LessonModel.fromJson(ModelJsonMap json) => LessonModel(
    id: ModelJson.requiredString(json, 'id'),
    courseId: ModelJson.requiredString(json, 'courseId'),
    moduleId: ModelJson.requiredString(json, 'moduleId'),
    title: ModelJson.requiredString(json, 'title'),
    description: ModelJson.requiredString(json, 'description'),
    content: ModelJson.objectList(json, 'content', LessonContentBlock.fromJson),
    objectives: ModelJson.stringList(json, 'objectives'),
    estimatedDuration: ModelJson.requiredDuration(json, 'estimatedDuration'),
    order: ModelJson.requiredInt(json, 'order'),
    difficulty: ModelJson.enumValue(
      DifficultyLevel.values,
      json['difficulty'],
      'difficulty',
    ),
    isCompleted: ModelJson.requiredBool(json, 'isCompleted'),
    format: json['format'] == null
        ? LessonFormat.text
        : ModelJson.enumValue(LessonFormat.values, json['format'], 'format'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'courseId': courseId,
    'moduleId': moduleId,
    'title': title,
    'description': description,
    'content': content.map((block) => block.toJson()).toList(),
    'objectives': objectives,
    'estimatedDuration': estimatedDuration.inMinutes,
    'order': order,
    'difficulty': difficulty.name,
    'isCompleted': isCompleted,
    'format': format.name,
  };
}
