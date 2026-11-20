import 'package:flutter_test/flutter_test.dart';
import 'package:naru/data/mock_repositories/mock_exercise_repository.dart';
import 'package:naru/data/mock_repositories/mock_learning_repository.dart';
import 'package:naru/data/mock_repositories/mock_progress_repository.dart';
import 'package:naru/data/mock_repositories/mock_user_repository.dart';
import 'package:naru/shared/mock/mock_data.dart';
import 'package:naru/shared/models/daily_goal_model.dart';
import 'package:naru/shared/models/enums/difficulty_level.dart';
import 'package:naru/shared/models/progress_model.dart';
import 'package:naru/shared/models/user_model.dart';

void main() {
  group('MockUserRepository', () {
    test(
      'returns the profile, preferences, latest goal, and notifications',
      () async {
        final repository = MockUserRepository();

        expect((await repository.getProfile())?.id, mockUser.id);
        final preferences = await repository.getPreferences();
        expect(preferences?.selectedDomains, mockUser.selectedDomains);
        expect(
          preferences?.dailyLearningMinutes,
          mockUser.dailyLearningMinutes,
        );
        expect((await repository.getDailyGoal())?.id, 'daily-goal-today');
        expect(
          await repository.getNotifications(),
          hasLength(mockNotifications.length),
        );
      },
    );

    test(
      'keeps profile changes in memory and exposes the updated preferences',
      () async {
        final repository = MockUserRepository();
        final updatedProfile = UserModel(
          id: mockUser.id,
          fullName: 'Samira Benali',
          email: mockUser.email,
          avatarUrl: mockUser.avatarUrl,
          selectedDomains: ['programmation'],
          currentLevel: DifficultyLevel.intermediate,
          learningGoals: ['Réviser les fonctions.'],
          dailyLearningMinutes: 30,
          joinedAt: mockUser.joinedAt,
          isOnboardingCompleted: mockUser.isOnboardingCompleted,
        );

        await repository.updateProfile(updatedProfile);

        expect(
          (await repository.getProfile())?.currentLevel,
          DifficultyLevel.intermediate,
        );
        expect((await repository.getPreferences())?.dailyLearningMinutes, 30);
        expect((await repository.getPreferences())?.selectedDomains, [
          'programmation',
        ]);
      },
    );

    test(
      'returns empty optional collections when initialized without them',
      () async {
        final repository = MockUserRepository(
          dailyGoals: const [],
          notifications: const [],
        );

        expect(await repository.getDailyGoal(), isNull);
        expect(await repository.getNotifications(), isEmpty);
      },
    );
  });

  group('MockLearningRepository', () {
    final repository = MockLearningRepository();

    test(
      'retrieves and filters courses without losing mock relationships',
      () async {
        expect(await repository.getDomains(), hasLength(12));
        expect(await repository.getCourses(), hasLength(22));
        expect(
          (await repository.getCoursesByDomain('programmation'))
              .map((course) => course.id),
          containsAll([
            'dart-fundamentals',
            'python-foundations',
            'git-basics',
          ]),
        );
        expect(await repository.getCoursesByDomain('unknown-domain'), isEmpty);
        expect(
          (await repository.searchCourses('  DART  '))
              .map((course) => course.id),
          contains('dart-fundamentals'),
        );
        expect(
          (await repository.searchCourses('Développement Web'))
              .map((course) => course.id),
          containsAll([
            'html-css-foundations',
            'javascript-basics',
            'web-accessibility',
          ]),
        );
        expect(
          (await repository.searchCourses('SQL')).map((course) => course.id),
          contains('sql-for-beginners'),
        );
        expect(await repository.searchCourses(''), isEmpty);
        expect(await repository.getCourseById('unknown-course'), isNull);
      },
    );

    test(
      'returns ordered modules and lessons and recommended courses',
      () async {
        final path = await repository.getLearningPathById(
          'path-flutter-beginner',
        );
        expect(path, isNotNull);
        final modules = await repository.getModulesForPath(path!.id);
        expect(modules, hasLength(6));
        expect(
          modules.map((module) => module.order),
          orderedEquals([1, 2, 3, 4, 5, 6]),
        );

        final lessons = await repository.getLessonsForModule(
          'module-dart-foundations',
        );
        expect(
          lessons.map((lesson) => lesson.order),
          orderedEquals([1, 2, 3, 4]),
        );
        expect(await repository.getLessonsForModule('unknown-module'), isEmpty);
        expect(await repository.getLessonById('unknown-lesson'), isNull);

        final recommended = await repository.getRecommendedCourses();
        expect(recommended, isNotEmpty);
        expect(recommended.every((course) => course.isRecommended), isTrue);
      },
    );
  });

  group('MockExerciseRepository', () {
    final repository = MockExerciseRepository();

    test('retrieves exercises by lesson, ID, and difficulty', () async {
      expect(await repository.getExercises(), hasLength(39));
      expect(
        await repository.getExercisesForLesson('dart-introduction'),
        hasLength(1),
      );
      expect(await repository.getExercisesForLesson('unknown-lesson'), isEmpty);
      expect(await repository.getExerciseById('unknown-exercise'), isNull);
      expect(
        (await repository.getExercisesByDifficulty(
          DifficultyLevel.intermediate,
        )).map((exercise) => exercise.id),
        containsAll(['exercise-flutter-navigation', 'exercise-ml-examples']),
      );
    });

    test(
      'checks simulated answers and returns null for unknown exercises',
      () async {
        expect(
          await repository.checkAnswer('exercise-dart-introduction', ' MAIN '),
          isTrue,
        );
        expect(
          await repository.checkAnswer('exercise-dart-introduction', 'print'),
          isFalse,
        );
        expect(
          await repository.checkAnswer(
            'exercise-dart-operators',
            '8   % 2 == 0',
          ),
          isTrue,
        );
        expect(
          await repository.checkAnswer('unknown-exercise', 'answer'),
          isNull,
        );
      },
    );
  });

  group('MockProgressRepository', () {
    test('reads overall, course, and skill progress', () async {
      final repository = MockProgressRepository();

      expect((await repository.getOverallProgress()).userId, mockUser.id);
      expect(await repository.getCourseProgress('algorithmic-thinking'), 100);
      expect(
        await repository.getCourseProgress('dart-fundamentals'),
        closeTo(4 / 12 * 100, 0.000001),
      );
      expect(await repository.getCourseProgress('unknown-course'), isNull);
      expect(await repository.getSkillProgress(), hasLength(8));
    });

    test('updates progress and daily goals in memory', () async {
      final repository = MockProgressRepository();
      final previousProgress = await repository.getOverallProgress();
      final updatedProgress = ProgressModel(
        userId: previousProgress.userId,
        totalLearningMinutes: previousProgress.totalLearningMinutes + 10,
        completedCourses: previousProgress.completedCourses,
        completedLessons: previousProgress.completedLessons,
        completedExercises: previousProgress.completedExercises,
        currentStreak: previousProgress.currentStreak,
        longestStreak: previousProgress.longestStreak,
        overallProgress: previousProgress.overallProgress,
        lastActivityAt: previousProgress.lastActivityAt,
      );
      await repository.saveProgress(updatedProgress);
      expect(
        (await repository.getOverallProgress()).totalLearningMinutes,
        updatedProgress.totalLearningMinutes,
      );

      final today = mockDailyGoals.last;
      final updatedGoal = DailyGoalModel(
        id: today.id,
        targetMinutes: today.targetMinutes,
        completedMinutes: today.completedMinutes + 5,
        targetLessons: today.targetLessons,
        completedLessons: today.completedLessons,
        date: today.date,
        isCompleted: true,
      );
      expect(await repository.updateDailyGoal(updatedGoal), same(updatedGoal));
      expect(
        (await repository.getDailyGoals()).last.completedMinutes,
        updatedGoal.completedMinutes,
      );
      expect(
        await repository.updateDailyGoal(
          DailyGoalModel(
            id: 'unknown-goal',
            targetMinutes: 10,
            completedMinutes: 0,
            targetLessons: 1,
            completedLessons: 0,
            date: today.date,
            isCompleted: false,
          ),
        ),
        isNull,
      );
    });

    test(
      'returns newest activities, unlocked badges, and respects the limit',
      () async {
        final repository = MockProgressRepository();
        final activities = await repository.getRecentActivities(limit: 3);

        expect(activities, hasLength(3));
        expect(
          activities[0].createdAt.isAfter(activities[1].createdAt) ||
              activities[0].createdAt.isAtSameMomentAs(activities[1].createdAt),
          isTrue,
        );
        expect(await repository.getRecentActivities(limit: 0), isEmpty);
        expect(
          (await repository.getUnlockedAchievements()).every(
            (achievement) => achievement.isUnlocked,
          ),
          isTrue,
        );
      },
    );
  });
}
