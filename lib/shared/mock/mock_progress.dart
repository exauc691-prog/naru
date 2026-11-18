import '../models/enums/difficulty_level.dart';
import '../models/progress_model.dart';
import '../models/skill_progress_model.dart';
import 'mock_courses.dart';
import 'mock_dates.dart';
import 'mock_lessons.dart';
import 'mock_user.dart';

final _completedLessons = mockLessons.where((lesson) => lesson.isCompleted);
final _completedCourses = mockCourses.where(
  (course) =>
      course.lessonsCount > 0 && course.completedLessons == course.lessonsCount,
);

final mockProgress = ProgressModel(
  userId: mockUser.id,
  totalLearningMinutes: 720,
  completedCourses: _completedCourses.length,
  completedLessons: _completedLessons.length,
  completedExercises: 14,
  currentStreak: 4,
  longestStreak: 9,
  overallProgress: mockLessons.isEmpty
      ? 0
      : _completedLessons.length / mockLessons.length * 100,
  lastActivityAt: mockDate(hour: 11, minute: 20),
);

final mockWeeklyLearningMinutes = List<int>.unmodifiable([
  15,
  0,
  18,
  25,
  30,
  24,
  25,
]);

final mockSkillProgress = List<SkillProgressModel>.unmodifiable([
  const SkillProgressModel(
    id: 'skill-dart-syntax',
    skillName: 'Syntaxe Dart',
    domainId: 'programmation',
    progressPercentage: 58.333333333333336,
    completedActivities: 7,
    totalActivities: 12,
    level: DifficultyLevel.beginner,
  ),
  const SkillProgressModel(
    id: 'skill-control-flow',
    skillName: 'Conditions et répétitions',
    domainId: 'programmation',
    progressPercentage: 33.333333333333336,
    completedActivities: 4,
    totalActivities: 12,
    level: DifficultyLevel.beginner,
  ),
  const SkillProgressModel(
    id: 'skill-collections',
    skillName: 'Collections',
    domainId: 'programmation',
    progressPercentage: 12.5,
    completedActivities: 1,
    totalActivities: 8,
    level: DifficultyLevel.beginner,
  ),
  const SkillProgressModel(
    id: 'skill-flutter-foundations',
    skillName: 'Bases de Flutter',
    domainId: 'developpement-mobile',
    progressPercentage: 30,
    completedActivities: 3,
    totalActivities: 10,
    level: DifficultyLevel.beginner,
  ),
  const SkillProgressModel(
    id: 'skill-web-structure',
    skillName: 'Structure Web',
    domainId: 'developpement-web',
    progressPercentage: 0,
    completedActivities: 0,
    totalActivities: 8,
    level: DifficultyLevel.beginner,
  ),
  const SkillProgressModel(
    id: 'skill-ai-literacy',
    skillName: 'Culture de l’IA',
    domainId: 'intelligence-artificielle',
    progressPercentage: 0,
    completedActivities: 0,
    totalActivities: 7,
    level: DifficultyLevel.beginner,
  ),
  const SkillProgressModel(
    id: 'skill-algorithmic-thinking',
    skillName: 'Pensée algorithmique',
    domainId: 'algorithmique',
    progressPercentage: 70,
    completedActivities: 7,
    totalActivities: 10,
    level: DifficultyLevel.intermediate,
  ),
  const SkillProgressModel(
    id: 'skill-sql-basics',
    skillName: 'Requêtes SQL',
    domainId: 'bases-de-donnees',
    progressPercentage: 0,
    completedActivities: 0,
    totalActivities: 6,
    level: DifficultyLevel.beginner,
  ),
]);
