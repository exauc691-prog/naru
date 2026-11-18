import 'enums/difficulty_level.dart';
import 'enums/exercise_type.dart';
import 'model_json.dart';

class ExerciseModel {
  ExerciseModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.question,
    required this.exerciseType,
    List<String> options = const [],
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.points,
  }) : options = List.unmodifiable(options);

  final String id;
  final String lessonId;
  final String title;
  final String question;
  final ExerciseType exerciseType;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final DifficultyLevel difficulty;
  final int points;

  factory ExerciseModel.fromJson(ModelJsonMap json) => ExerciseModel(
    id: ModelJson.requiredString(json, 'id'),
    lessonId: ModelJson.requiredString(json, 'lessonId'),
    title: ModelJson.requiredString(json, 'title'),
    question: ModelJson.requiredString(json, 'question'),
    exerciseType: ModelJson.enumValue(
      ExerciseType.values,
      json['exerciseType'],
      'exerciseType',
    ),
    options: ModelJson.optionalStringList(json, 'options'),
    correctAnswer: ModelJson.requiredString(json, 'correctAnswer'),
    explanation: ModelJson.requiredString(json, 'explanation'),
    difficulty: ModelJson.enumValue(
      DifficultyLevel.values,
      json['difficulty'],
      'difficulty',
    ),
    points: ModelJson.requiredInt(json, 'points'),
  );

  ModelJsonMap toJson() => {
    'id': id,
    'lessonId': lessonId,
    'title': title,
    'question': question,
    'exerciseType': exerciseType.name,
    'options': options,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
    'difficulty': difficulty.name,
    'points': points,
  };
}
