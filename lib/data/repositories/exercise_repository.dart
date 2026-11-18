import '../../shared/models/enums/difficulty_level.dart';
import '../../shared/models/exercise_model.dart';

abstract interface class ExerciseRepository {
  Future<List<ExerciseModel>> getExercises();

  Future<List<ExerciseModel>> getExercisesForLesson(String lessonId);

  Future<ExerciseModel?> getExerciseById(String exerciseId);

  Future<List<ExerciseModel>> getExercisesByDifficulty(
    DifficultyLevel difficulty,
  );

  /// Returns null when the exercise does not exist.
  Future<bool?> checkAnswer(String exerciseId, String answer);
}
