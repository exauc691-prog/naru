import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/repository_providers.dart';
import '../../../shared/models/enums/difficulty_level.dart';
import '../../../shared/models/exercise_model.dart';

final exercisesProvider = FutureProvider<List<ExerciseModel>>(
  (ref) => ref.watch(exerciseRepositoryProvider).getExercises(),
);

final exercisesForLessonProvider =
    FutureProvider.family<List<ExerciseModel>, String>((ref, lessonId) {
      return ref
          .watch(exerciseRepositoryProvider)
          .getExercisesForLesson(lessonId);
    });

final exerciseByIdProvider = FutureProvider.family<ExerciseModel?, String>((
  ref,
  exerciseId,
) {
  return ref.watch(exerciseRepositoryProvider).getExerciseById(exerciseId);
});

final exercisesByDifficultyProvider =
    FutureProvider.family<List<ExerciseModel>, DifficultyLevel>((
      ref,
      difficulty,
    ) {
      return ref
          .watch(exerciseRepositoryProvider)
          .getExercisesByDifficulty(difficulty);
    });
