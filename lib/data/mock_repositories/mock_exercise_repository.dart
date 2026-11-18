import '../../shared/mock/mock_data.dart';
import '../../shared/models/enums/difficulty_level.dart';
import '../../shared/models/enums/exercise_type.dart';
import '../../shared/models/exercise_model.dart';
import '../repositories/exercise_repository.dart';

class MockExerciseRepository implements ExerciseRepository {
  MockExerciseRepository({Iterable<ExerciseModel>? exercises})
    : _exercises = List.unmodifiable(exercises ?? mockExercises);

  final List<ExerciseModel> _exercises;

  @override
  Future<List<ExerciseModel>> getExercises() async => _exercises;

  @override
  Future<List<ExerciseModel>> getExercisesForLesson(String lessonId) async =>
      List.unmodifiable(
        _exercises.where((exercise) => exercise.lessonId == lessonId),
      );

  @override
  Future<ExerciseModel?> getExerciseById(String exerciseId) async {
    for (final exercise in _exercises) {
      if (exercise.id == exerciseId) return exercise;
    }
    return null;
  }

  @override
  Future<List<ExerciseModel>> getExercisesByDifficulty(
    DifficultyLevel difficulty,
  ) async => List.unmodifiable(
    _exercises.where((exercise) => exercise.difficulty == difficulty),
  );

  @override
  Future<bool?> checkAnswer(String exerciseId, String answer) async {
    final exercise = await getExerciseById(exerciseId);
    if (exercise == null) return null;

    final submitted = _normalizeWhitespace(answer);
    final expected = _normalizeWhitespace(exercise.correctAnswer);
    if (exercise.exerciseType == ExerciseType.codingChallenge) {
      return submitted == expected;
    }
    return submitted.toLowerCase() == expected.toLowerCase();
  }

  String _normalizeWhitespace(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
