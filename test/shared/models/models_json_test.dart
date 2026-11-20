import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:naru/shared/models/achievement_model.dart';
import 'package:naru/shared/models/ai_conversation_model.dart';
import 'package:naru/shared/models/ai_message_model.dart';
import 'package:naru/shared/models/course_model.dart';
import 'package:naru/shared/models/daily_goal_model.dart';
import 'package:naru/shared/models/enums/achievement_category.dart';
import 'package:naru/shared/models/enums/ai_message_sender.dart';
import 'package:naru/shared/models/enums/ai_message_type.dart';
import 'package:naru/shared/models/enums/course_format.dart';
import 'package:naru/shared/models/enums/difficulty_level.dart';
import 'package:naru/shared/models/enums/exercise_type.dart';
import 'package:naru/shared/models/enums/learning_activity_type.dart';
import 'package:naru/shared/models/enums/lesson_format.dart';
import 'package:naru/shared/models/enums/lesson_content_type.dart';
import 'package:naru/shared/models/enums/notification_type.dart';
import 'package:naru/shared/models/exercise_model.dart';
import 'package:naru/shared/models/learning_activity_model.dart';
import 'package:naru/shared/models/learning_domain_model.dart';
import 'package:naru/shared/models/learning_path_model.dart';
import 'package:naru/shared/models/lesson_content_block.dart';
import 'package:naru/shared/models/lesson_model.dart';
import 'package:naru/shared/models/model_json.dart';
import 'package:naru/shared/models/module_model.dart';
import 'package:naru/shared/models/notification_model.dart';
import 'package:naru/shared/models/progress_model.dart';
import 'package:naru/shared/models/skill_progress_model.dart';
import 'package:naru/shared/models/user_model.dart';

void main() {
  final joinedAt = DateTime.utc(2025, 1, 2, 3, 4);

  test('round-trips all models through JSON', () {
    final user = UserModel(
      id: 'user-1',
      fullName: 'Ada Lovelace',
      email: 'ada@example.com',
      selectedDomains: ['math'],
      currentLevel: DifficultyLevel.intermediate,
      learningGoals: ['Learn algorithms'],
      dailyLearningMinutes: 20,
      joinedAt: joinedAt,
      isOnboardingCompleted: true,
    );
    final domain = LearningDomainModel(
      id: 'math',
      name: 'Mathematics',
      description: 'Explore mathematical ideas.',
      icon: 'calculate',
      colorCode: '#4F46E5',
      availableCoursesCount: 4,
      difficultyLevels: DifficultyLevel.values,
    );
    final course = CourseModel(
      id: 'course-1',
      title: 'Algorithms',
      description: 'An introduction to algorithms.',
      domainId: domain.id,
      instructorName: 'Ada',
      difficulty: DifficultyLevel.beginner,
      estimatedDuration: const Duration(minutes: 90),
      lessonsCount: 6,
      completedLessons: 2,
      rating: 4.8,
      tags: ['logic', 'coding'],
      isRecommended: true,
      isNew: true,
      isPremium: true,
      format: CourseFormat.video,
      enrolledStudents: 1250,
      publishedAt: joinedAt,
      prerequisites: ['Basic arithmetic'],
    );
    final path = LearningPathModel(
      id: 'path-1',
      title: 'Computational thinking',
      description: 'A guided learning path.',
      domainId: domain.id,
      level: DifficultyLevel.intermediate,
      estimatedDuration: const Duration(hours: 4),
      courseIds: [course.id],
      moduleIds: ['module-1'],
      progressPercentage: 25,
      isCompleted: false,
    );
    final module = ModuleModel(
      id: 'module-1',
      learningPathId: path.id,
      title: 'Foundations',
      description: 'Start with the basics.',
      order: 1,
      lessonIds: ['lesson-1'],
      isCompleted: false,
    );
    final lessonContent = <LessonContentBlock>[
      const LessonParagraphBlock(text: 'An algorithm is a set of steps.'),
      const LessonHeadingBlock(text: 'Example', level: 2),
      LessonListBlock(items: ['Input', 'Process', 'Output'], ordered: true),
      const LessonCodeBlock(code: 'print("hello")', language: 'python'),
      LessonExampleBlock(
        title: 'A small example',
        content: const [
          LessonParagraphBlock(text: 'Display a greeting.'),
          LessonCodeBlock(code: 'print("hello")'),
        ],
      ),
      const LessonImageBlock(
        url: 'https://example.com/diagram.png',
        altText: 'A simple diagram',
        caption: 'Algorithm flow',
      ),
      const LessonImportantPointBlock(text: 'Make each step precise.'),
    ];
    final lesson = LessonModel(
      id: 'lesson-1',
      courseId: course.id,
      moduleId: module.id,
      title: 'What is an algorithm?',
      description: 'Learn the basic concept.',
      content: lessonContent,
      objectives: ['Define an algorithm'],
      estimatedDuration: const Duration(minutes: 12),
      order: 1,
      difficulty: DifficultyLevel.beginner,
      isCompleted: false,
      format: LessonFormat.audio,
    );
    final exercise = ExerciseModel(
      id: 'exercise-1',
      lessonId: lesson.id,
      title: 'Check your understanding',
      question: 'Is an algorithm a sequence of steps?',
      exerciseType: ExerciseType.trueFalse,
      correctAnswer: 'true',
      explanation: 'An algorithm is a defined sequence of steps.',
      difficulty: DifficultyLevel.beginner,
      points: 10,
    );
    final progress = ProgressModel(
      userId: user.id,
      totalLearningMinutes: 120,
      completedCourses: 1,
      completedLessons: 3,
      completedExercises: 4,
      currentStreak: 2,
      longestStreak: 5,
      overallProgress: 35.5,
      lastActivityAt: joinedAt,
    );
    final skill = SkillProgressModel(
      id: 'skill-1',
      skillName: 'Algorithmic thinking',
      domainId: domain.id,
      progressPercentage: 50,
      completedActivities: 5,
      totalActivities: 10,
      level: DifficultyLevel.intermediate,
    );
    final achievement = AchievementModel(
      id: 'achievement-1',
      title: 'First steps',
      description: 'Complete your first lesson.',
      icon: 'flag',
      category: AchievementCategory.learning,
      unlockedAt: joinedAt,
      isUnlocked: true,
    );
    final notification = NotificationModel(
      id: 'notification-1',
      title: 'Daily goal',
      message: 'Keep up your learning streak.',
      type: NotificationType.reminder,
      createdAt: joinedAt,
      isRead: false,
    );
    final userMessage = AIMessageModel(
      id: 'message-1',
      conversationId: 'conversation-1',
      content: 'Can you explain this example?',
      sender: AIMessageSender.user,
      createdAt: joinedAt,
      messageType: AIMessageType.text,
    );
    final assistantMessage = AIMessageModel(
      id: 'message-2',
      conversationId: 'conversation-1',
      content: 'Here is a short code sample.',
      sender: AIMessageSender.assistant,
      createdAt: joinedAt.add(const Duration(minutes: 1)),
      messageType: AIMessageType.code,
    );
    final conversation = AIConversationModel(
      id: 'conversation-1',
      title: 'Algorithms help',
      messages: [userMessage, assistantMessage],
      createdAt: joinedAt,
      updatedAt: joinedAt.add(const Duration(minutes: 1)),
    );
    final dailyGoal = DailyGoalModel(
      id: 'goal-1',
      targetMinutes: 20,
      completedMinutes: 10,
      targetLessons: 1,
      completedLessons: 0,
      date: joinedAt,
      isCompleted: false,
    );
    final activity = LearningActivityModel(
      id: 'activity-1',
      activityType: LearningActivityType.lessonCompleted,
      title: 'Lesson completed',
      description: 'You completed an introduction.',
      relatedId: lesson.id,
      createdAt: joinedAt,
      durationMinutes: 12,
    );

    expectRoundTrip(user, (model) => model.toJson(), UserModel.fromJson);
    expectRoundTrip(
      domain,
      (model) => model.toJson(),
      LearningDomainModel.fromJson,
    );
    expectRoundTrip(course, (model) => model.toJson(), CourseModel.fromJson);
    final legacyCourseJson = course.toJson()
      ..remove('isNew')
      ..remove('isPremium')
      ..remove('format')
      ..remove('enrolledStudents')
      ..remove('publishedAt')
      ..remove('prerequisites');
    final legacyCourse = CourseModel.fromJson(legacyCourseJson);
    expect(legacyCourse.isNew, isFalse);
    expect(legacyCourse.isPremium, isFalse);
    expect(legacyCourse.format, CourseFormat.mixed);
    expect(legacyCourse.enrolledStudents, 0);
    expect(legacyCourse.publishedAt, isNull);
    expect(legacyCourse.prerequisites, isEmpty);
    expectRoundTrip(
      path,
      (model) => model.toJson(),
      LearningPathModel.fromJson,
    );
    expectRoundTrip(module, (model) => model.toJson(), ModuleModel.fromJson);
    expectRoundTrip(lesson, (model) => model.toJson(), LessonModel.fromJson);
    final legacyLessonJson = lesson.toJson()..remove('format');
    expect(LessonModel.fromJson(legacyLessonJson).format, LessonFormat.text);
    expectRoundTrip(
      exercise,
      (model) => model.toJson(),
      ExerciseModel.fromJson,
    );
    expectRoundTrip(
      progress,
      (model) => model.toJson(),
      ProgressModel.fromJson,
    );
    expectRoundTrip(
      skill,
      (model) => model.toJson(),
      SkillProgressModel.fromJson,
    );
    expectRoundTrip(
      achievement,
      (model) => model.toJson(),
      AchievementModel.fromJson,
    );
    expectRoundTrip(
      notification,
      (model) => model.toJson(),
      NotificationModel.fromJson,
    );
    expectRoundTrip(
      userMessage,
      (model) => model.toJson(),
      AIMessageModel.fromJson,
    );
    expectRoundTrip(
      conversation,
      (model) => model.toJson(),
      AIConversationModel.fromJson,
    );
    expectRoundTrip(
      dailyGoal,
      (model) => model.toJson(),
      DailyGoalModel.fromJson,
    );
    expectRoundTrip(
      activity,
      (model) => model.toJson(),
      LearningActivityModel.fromJson,
    );
    expect(
      lessonContent.map((block) => block.type).toList(),
      LessonContentType.values,
    );
    expect(user.selectedDomains, contains(domain.id));
    expect(course.domainId, domain.id);
    expect(path.domainId, domain.id);
    expect(path.courseIds, contains(course.id));
    expect(path.moduleIds, contains(module.id));
    expect(module.learningPathId, path.id);
    expect(lesson.courseId, course.id);
    expect(lesson.moduleId, module.id);
    expect(exercise.lessonId, lesson.id);
    expect(progress.userId, user.id);
    expect(skill.domainId, domain.id);
    expect(
      conversation.messages.every(
        (message) => message.conversationId == conversation.id,
      ),
      isTrue,
    );
    expect(activity.relatedId, lesson.id);
  });

  test('round-trips every exercise type', () {
    for (final type in ExerciseType.values) {
      final exercise = ExerciseModel(
        id: 'exercise-${type.name}',
        lessonId: 'lesson-1',
        title: 'Exercise',
        question: 'Question',
        exerciseType: type,
        options: type == ExerciseType.multipleChoice ? ['A', 'B'] : const [],
        correctAnswer: 'A',
        explanation: 'Explanation',
        difficulty: DifficultyLevel.beginner,
        points: 5,
      );

      expectRoundTrip(
        exercise,
        (model) => model.toJson(),
        ExerciseModel.fromJson,
      );
    }
  });

  test('retains identifiers across model relationships', () {
    final path = LearningPathModel(
      id: 'path-1',
      title: 'Path',
      description: 'Description',
      domainId: 'domain-1',
      level: DifficultyLevel.beginner,
      estimatedDuration: const Duration(minutes: 30),
      courseIds: ['course-1'],
      moduleIds: ['module-1'],
      progressPercentage: 0,
      isCompleted: false,
    );
    final module = ModuleModel(
      id: 'module-1',
      learningPathId: path.id,
      title: 'Module',
      description: 'Description',
      order: 0,
      lessonIds: ['lesson-1'],
      isCompleted: false,
    );

    expect(path.courseIds, contains('course-1'));
    expect(path.moduleIds, contains(module.id));
    expect(module.learningPathId, path.id);
    expect(module.lessonIds, contains('lesson-1'));
  });

  test('rejects missing required fields and unknown enum values', () {
    expect(() => UserModel.fromJson({'id': 'user-1'}), throwsFormatException);
    expect(
      () => ModelJson.enumValue(DifficultyLevel.values, 'expert', 'difficulty'),
      throwsFormatException,
    );
  });

  test('model collections cannot be modified through their public fields', () {
    final user = UserModel(
      id: 'user-1',
      fullName: 'Ada Lovelace',
      email: 'ada@example.com',
      selectedDomains: ['math'],
      currentLevel: DifficultyLevel.beginner,
      learningGoals: [],
      dailyLearningMinutes: 15,
      joinedAt: joinedAt,
      isOnboardingCompleted: false,
    );

    expect(() => user.selectedDomains.add('science'), throwsUnsupportedError);
  });
}

void expectRoundTrip<T>(
  T model,
  ModelJsonMap Function(T) toJson,
  T Function(ModelJsonMap) fromJson,
) {
  final encoded = jsonEncode(toJson(model));
  final decoded = ModelJson.object(jsonDecode(encoded), 'model');
  final restored = fromJson(decoded);

  expect(jsonEncode(toJson(restored)), encoded);
}
