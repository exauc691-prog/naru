import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/app/providers/app_providers.dart';
import 'package:naru/data/mock_repositories/mock_exercise_repository.dart';
import 'package:naru/data/mock_repositories/mock_learning_repository.dart';
import 'package:naru/data/mock_repositories/mock_progress_repository.dart';
import 'package:naru/data/mock_repositories/mock_user_repository.dart';
import 'package:naru/features/learning/providers/learning_providers.dart';
import 'package:naru/features/practice/providers/practice_providers.dart';
import 'package:naru/features/progress/providers/progress_providers.dart';
import 'package:naru/shared/models/enums/difficulty_level.dart';

void main() {
  test('repository providers supply the existing mock implementations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(userRepositoryProvider), isA<MockUserRepository>());
    expect(
      container.read(learningRepositoryProvider),
      isA<MockLearningRepository>(),
    );
    expect(
      container.read(exerciseRepositoryProvider),
      isA<MockExerciseRepository>(),
    );
    expect(
      container.read(progressRepositoryProvider),
      isA<MockProgressRepository>(),
    );
  });

  test('feature providers expose asynchronous mock data and lookups', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      (await container.read(userProfileProvider.future))?.id,
      'user-samira-01',
    );
    expect(await container.read(learningDomainsProvider.future), hasLength(12));
    expect(await container.read(coursesProvider.future), hasLength(22));
    expect(
      (await container.read(courseByIdProvider('dart-fundamentals').future))
          ?.title,
      'Apprendre Dart de zéro',
    );
    expect(
      await container.read(courseSearchProvider('DART').future),
      isNotEmpty,
    );
    expect(
      await container.read(
        modulesForPathProvider('path-flutter-beginner').future,
      ),
      hasLength(6),
    );
    expect(
      await container.read(
        exercisesByDifficultyProvider(DifficultyLevel.beginner).future,
      ),
      isNotEmpty,
    );
    expect(
      await container.read(
        courseProgressProvider('algorithmic-thinking').future,
      ),
      100,
    );
    expect(await container.read(dailyGoalsProvider.future), hasLength(7));
    expect(
      await container.read(unlockedAchievementsProvider.future),
      isNotEmpty,
    );
  });

  test(
    'repository providers can be overridden without changing feature providers',
    () async {
      final emptyLearningRepository = MockLearningRepository(courses: const []);
      final container = ProviderContainer(
        overrides: [
          learningRepositoryProvider.overrideWithValue(emptyLearningRepository),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(coursesProvider.future), isEmpty);
    },
  );
}
