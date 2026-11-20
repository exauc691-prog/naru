import 'package:flutter_test/flutter_test.dart';
import 'package:naru/shared/mock/mock_data.dart';
import 'package:naru/shared/models/enums/exercise_type.dart';
import 'package:naru/shared/models/enums/learning_activity_type.dart';

void main() {
  test('provides the requested breadth of mock learning content', () {
    expect(mockDomains, hasLength(12));
    expect(mockCourses.length, greaterThanOrEqualTo(20));
    expect(mockLearningPaths.length, greaterThanOrEqualTo(5));
    expect(mockLessons, hasLength(39));
    expect(mockExercises.length, greaterThanOrEqualTo(30));
    expect(mockAchievements, hasLength(12));
    expect(mockDailyGoals, hasLength(7));
    expect(mockAIConversations, hasLength(4));

    expect(
      mockLessons
          .where((lesson) => lesson.courseId == 'dart-fundamentals')
          .map((lesson) => lesson.id),
      containsAll([
        'dart-introduction',
        'dart-variables',
        'dart-data-types',
        'dart-operators',
        'dart-conditions',
        'dart-loops',
        'dart-functions',
        'dart-lists',
        'dart-maps',
        'dart-sets',
        'dart-classes',
        'dart-objects',
      ]),
    );
    expect(
      mockExercises.map((exercise) => exercise.exerciseType).toSet(),
      containsAll(ExerciseType.values),
    );
  });

  test(
    'uses unique identifiers and valid domain, course, path, and lesson links',
    () {
      _expectUnique(mockDomains.map((domain) => domain.id));
      _expectUnique(mockCourses.map((course) => course.id));
      _expectUnique(mockLearningPaths.map((path) => path.id));
      _expectUnique(mockModules.map((module) => module.id));
      _expectUnique(mockLessons.map((lesson) => lesson.id));
      _expectUnique(mockExercises.map((exercise) => exercise.id));

      final domainIds = mockDomains.map((domain) => domain.id).toSet();
      final courseById = {for (final course in mockCourses) course.id: course};
      final pathById = {for (final path in mockLearningPaths) path.id: path};
      final moduleById = {for (final module in mockModules) module.id: module};
      final lessonById = {for (final lesson in mockLessons) lesson.id: lesson};

      expect(mockUser.selectedDomains, everyElement(isIn(domainIds)));
      expect(mockProgress.userId, mockUser.id);

      for (final domain in mockDomains) {
        final domainCourses = mockCourses
            .where((course) => course.domainId == domain.id)
            .length;
        expect(domain.availableCoursesCount, domainCourses, reason: domain.id);
      }

      for (final course in mockCourses) {
        expect(domainIds, contains(course.domainId), reason: course.id);
        final courseLessons = mockLessons
            .where((lesson) => lesson.courseId == course.id)
            .toList();
        expect(course.lessonsCount, courseLessons.length, reason: course.id);
        expect(
          course.completedLessons,
          courseLessons.where((lesson) => lesson.isCompleted).length,
          reason: course.id,
        );
      }

      for (final path in mockLearningPaths) {
        expect(domainIds, contains(path.domainId), reason: path.id);
        expect(
          path.courseIds.every(courseById.containsKey),
          isTrue,
          reason: path.id,
        );
        expect(
          path.moduleIds.every(moduleById.containsKey),
          isTrue,
          reason: path.id,
        );

        final pathModules = mockModules
            .where((module) => module.learningPathId == path.id)
            .toList();
        expect(
          path.moduleIds.toSet(),
          pathModules.map((module) => module.id).toSet(),
          reason: path.id,
        );

        final pathLessons = pathModules
            .expand((module) => module.lessonIds)
            .map((lessonId) => lessonById[lessonId]!)
            .toList();
        final completedLessons = pathLessons
            .where((lesson) => lesson.isCompleted)
            .length;
        final expectedProgress = pathLessons.isEmpty
            ? 0.0
            : completedLessons / pathLessons.length * 100;
        expect(path.progressPercentage, closeTo(expectedProgress, 0.000001));
        expect(
          path.isCompleted,
          pathLessons.isNotEmpty && completedLessons == pathLessons.length,
        );
      }

      for (final module in mockModules) {
        expect(pathById, contains(module.learningPathId), reason: module.id);
        expect(module.lessonIds, isNotEmpty, reason: module.id);
        final moduleLessons = module.lessonIds
            .map((lessonId) => lessonById[lessonId]!)
            .toList();
        expect(
          moduleLessons.every((lesson) => lesson.moduleId == module.id),
          isTrue,
          reason: module.id,
        );
        expect(
          module.isCompleted,
          moduleLessons.every((lesson) => lesson.isCompleted),
          reason: module.id,
        );
      }

      for (final lesson in mockLessons) {
        expect(courseById, contains(lesson.courseId), reason: lesson.id);
        expect(moduleById, contains(lesson.moduleId), reason: lesson.id);
        expect(
          moduleById[lesson.moduleId]!.learningPathId,
          isIn(pathById.keys),
          reason: lesson.id,
        );
      }

      for (final exercise in mockExercises) {
        expect(lessonById, contains(exercise.lessonId), reason: exercise.id);
        if (exercise.exerciseType == ExerciseType.multipleChoice) {
          expect(exercise.options, contains(exercise.correctAnswer));
          expect(exercise.options.length, greaterThanOrEqualTo(2));
        }
      }
    },
  );

  test(
    'keeps progress, goals, skills, achievements, and recommendations coherent',
    () {
      final completedLessons = mockLessons.where(
        (lesson) => lesson.isCompleted,
      );
      final completedCourses = mockCourses.where(
        (course) =>
            course.lessonsCount > 0 &&
            course.completedLessons == course.lessonsCount,
      );

      expect(mockProgress.completedLessons, completedLessons.length);
      expect(mockProgress.completedCourses, completedCourses.length);
      expect(
        mockProgress.completedLessons,
        lessThanOrEqualTo(mockLessons.length),
      );
      expect(
        mockProgress.completedExercises,
        lessThanOrEqualTo(mockExercises.length),
      );
      expect(
        mockProgress.currentStreak,
        lessThanOrEqualTo(mockProgress.longestStreak),
      );
      expect(
        mockProgress.overallProgress,
        closeTo(completedLessons.length / mockLessons.length * 100, 0.000001),
      );

      for (final skill in mockSkillProgress) {
        expect(
          skill.progressPercentage,
          closeTo(
            skill.completedActivities / skill.totalActivities * 100,
            0.000001,
          ),
          reason: skill.id,
        );
        expect(
          skill.completedActivities,
          lessThanOrEqualTo(skill.totalActivities),
        );
      }

      for (final goal in mockDailyGoals) {
        expect(
          goal.isCompleted,
          goal.completedMinutes >= goal.targetMinutes &&
              goal.completedLessons >= goal.targetLessons,
          reason: goal.id,
        );
      }
      expect(
        mockWeeklyLearningMinutes,
        mockDailyGoals.map((goal) => goal.completedMinutes),
      );

      for (final achievement in mockAchievements) {
        expect(achievement.isUnlocked, achievement.unlockedAt != null);
      }

      expect(
        mockRecommendedCourseReasons.keys,
        everyElement(isIn(mockCourses.map((course) => course.id))),
      );
      expect(
        mockRecommendedLearningPathReasons.keys,
        everyElement(isIn(mockLearningPaths.map((path) => path.id))),
      );
      expect(
        mockRecommendedCourseReasons.keys.every(
          (id) =>
              mockCourses.firstWhere((course) => course.id == id).isRecommended,
        ),
        isTrue,
      );
    },
  );

  test(
    'keeps conversations and activity references attached to mock records',
    () {
      _expectUnique(mockAchievements.map((achievement) => achievement.id));
      _expectUnique(mockNotifications.map((notification) => notification.id));
      _expectUnique(mockLearningActivities.map((activity) => activity.id));

      final lessonIds = mockLessons.map((lesson) => lesson.id).toSet();
      final courseIds = mockCourses.map((course) => course.id).toSet();
      final exerciseIds = mockExercises.map((exercise) => exercise.id).toSet();
      final achievementIds = mockAchievements
          .map((achievement) => achievement.id)
          .toSet();
      final goalIds = mockDailyGoals.map((goal) => goal.id).toSet();

      for (final conversation in mockAIConversations) {
        expect(conversation.messages, isNotEmpty);
        _expectUnique(conversation.messages.map((message) => message.id));
        expect(
          conversation.messages.every(
            (message) => message.conversationId == conversation.id,
          ),
          isTrue,
        );
        expect(conversation.updatedAt, conversation.messages.last.createdAt);
      }

      for (final activity in mockLearningActivities) {
        final isValid = switch (activity.activityType) {
          LearningActivityType.courseStarted ||
          LearningActivityType.courseCompleted => courseIds.contains(
            activity.relatedId,
          ),
          LearningActivityType.lessonCompleted => lessonIds.contains(
            activity.relatedId,
          ),
          LearningActivityType.exerciseCompleted => exerciseIds.contains(
            activity.relatedId,
          ),
          LearningActivityType.goalCompleted => goalIds.contains(
            activity.relatedId,
          ),
          LearningActivityType.achievementUnlocked => achievementIds.contains(
            activity.relatedId,
          ),
        };
        expect(isValid, isTrue, reason: activity.id);
      }
    },
  );
}

void _expectUnique(Iterable<String> ids) {
  final idList = ids.toList();
  expect(idList.toSet(), hasLength(idList.length));
}
