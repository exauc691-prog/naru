import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_repositories/mock_exercise_repository.dart';
import '../../data/mock_repositories/mock_learning_repository.dart';
import '../../data/mock_repositories/mock_progress_repository.dart';
import '../../data/mock_repositories/mock_user_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/learning_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => MockUserRepository(),
);

final learningRepositoryProvider = Provider<LearningRepository>(
  (ref) => MockLearningRepository(),
);

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => MockExerciseRepository(),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => MockProgressRepository(),
);
