import '../models/enums/learning_activity_type.dart';
import '../models/learning_activity_model.dart';
import 'mock_dates.dart';

final mockLearningActivities = List<LearningActivityModel>.unmodifiable([
  LearningActivityModel(
    id: 'activity-goal-today',
    activityType: LearningActivityType.goalCompleted,
    title: 'Objectif quotidien atteint',
    description: '25 minutes d’apprentissage et une leçon terminée.',
    relatedId: 'daily-goal-today',
    createdAt: mockDate(hour: 11, minute: 20),
    durationMinutes: 25,
  ),
  LearningActivityModel(
    id: 'activity-dart-operators',
    activityType: LearningActivityType.lessonCompleted,
    title: 'Leçon terminée : Opérateurs et expressions',
    description:
        'Tu as révisé les calculs, comparaisons et opérateurs logiques.',
    relatedId: 'dart-operators',
    createdAt: mockDate(hour: 10, minute: 55),
    durationMinutes: 20,
  ),
  LearningActivityModel(
    id: 'activity-dart-exercise',
    activityType: LearningActivityType.exerciseCompleted,
    title: 'Exercice réussi : Calculer un reste',
    description: 'Tu as utilisé le modulo pour vérifier si un nombre est pair.',
    relatedId: 'exercise-dart-operators',
    createdAt: mockDate(hour: 10, minute: 35),
    durationMinutes: 5,
  ),
  LearningActivityModel(
    id: 'activity-explorer-badge',
    activityType: LearningActivityType.achievementUnlocked,
    title: 'Badge obtenu : Curiosité en action',
    description: 'Tu as exploré plusieurs domaines d’apprentissage.',
    relatedId: 'achievement-explorer',
    createdAt: mockDate(daysAgo: 1, hour: 12, minute: 10),
  ),
  LearningActivityModel(
    id: 'activity-flutter-course',
    activityType: LearningActivityType.courseStarted,
    title: 'Nouveau cours commencé',
    description: 'Tu as commencé Construire des interfaces Flutter.',
    relatedId: 'flutter-layouts',
    createdAt: mockDate(daysAgo: 2, hour: 17),
  ),
  LearningActivityModel(
    id: 'activity-algorithm-course',
    activityType: LearningActivityType.courseCompleted,
    title: 'Cours terminé : Penser comme un algorithme',
    description: 'Tu as suivi toutes les étapes de ce cours.',
    relatedId: 'algorithmic-thinking',
    createdAt: mockDate(daysAgo: 6, hour: 16),
    durationMinutes: 75,
  ),
  LearningActivityModel(
    id: 'activity-first-lesson',
    activityType: LearningActivityType.lessonCompleted,
    title: 'Première leçon terminée',
    description: 'Tu as découvert Dart et lancé ton premier exemple.',
    relatedId: 'dart-introduction',
    createdAt: mockDate(daysAgo: 10, hour: 15),
    durationMinutes: 20,
  ),
]);
