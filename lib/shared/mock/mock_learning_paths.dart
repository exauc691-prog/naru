import '../models/enums/difficulty_level.dart';
import '../models/learning_path_model.dart';
import 'mock_lessons.dart';
import 'mock_modules.dart';

final mockLearningPaths = List<LearningPathModel>.unmodifiable([
  _path(
    id: 'path-flutter-beginner',
    title: 'Parcours Développeur Flutter débutant',
    description:
        'Des bases de Dart à une première application mobile structurée.',
    domainId: 'developpement-mobile',
    estimatedDuration: const Duration(minutes: 645),
    courseIds: [
      'dart-fundamentals',
      'flutter-introduction',
      'flutter-layouts',
      'flutter-navigation',
      'flutter-state',
    ],
    moduleIds: [
      'module-dart-foundations',
      'module-dart-control-flow',
      'module-dart-collections',
      'module-dart-objects',
      'module-flutter-foundations',
      'module-flutter-navigation-state',
    ],
  ),
  _path(
    id: 'path-web-foundations',
    title: 'Parcours Développeur Web',
    description:
        'Construis des pages structurées, interactives et accessibles.',
    domainId: 'developpement-web',
    estimatedDuration: const Duration(minutes: 300),
    courseIds: [
      'html-css-foundations',
      'javascript-basics',
      'web-accessibility',
    ],
    moduleIds: ['module-web-structure', 'module-web-javascript'],
  ),
  _path(
    id: 'path-python-beginner',
    title: 'Parcours Python débutant',
    description:
        'Écris tes premiers scripts et découvre un flux de travail versionné.',
    domainId: 'programmation',
    estimatedDuration: const Duration(minutes: 135),
    courseIds: ['python-foundations', 'git-basics'],
    moduleIds: ['module-python-foundations', 'module-git-basics'],
  ),
  _path(
    id: 'path-ai-foundations',
    title: 'Parcours Intelligence artificielle',
    description:
        'Comprends les modèles, leurs données et les précautions d’usage.',
    domainId: 'intelligence-artificielle',
    estimatedDuration: const Duration(minutes: 255),
    courseIds: ['ai-foundations', 'responsible-ai', 'machine-learning-intro'],
    moduleIds: [
      'module-ai-foundations',
      'module-ai-responsible-use',
      'module-ai-machine-learning',
    ],
  ),
  _path(
    id: 'path-database-foundations',
    title: 'Parcours Bases de données et SQL',
    description: 'Organise des données puis réponds à des questions avec SQL.',
    domainId: 'bases-de-donnees',
    estimatedDuration: const Duration(minutes: 150),
    courseIds: ['database-concepts', 'sql-for-beginners'],
    moduleIds: ['module-database-concepts', 'module-sql-queries'],
  ),
  _path(
    id: 'path-cyber-safety',
    title: 'Parcours Cybersécurité au quotidien',
    description: 'Adopte des habitudes utiles pour protéger tes comptes.',
    domainId: 'cybersecurite',
    estimatedDuration: const Duration(minutes: 60),
    courseIds: ['cybersecurity-fundamentals'],
    moduleIds: ['module-cybersecurity-basics'],
  ),
  _path(
    id: 'path-algorithmic-thinking',
    title: 'Parcours Pensée algorithmique',
    description: 'Apprends à décomposer un problème et à tester une solution.',
    domainId: 'algorithmique',
    estimatedDuration: const Duration(minutes: 75),
    courseIds: ['algorithmic-thinking'],
    moduleIds: ['module-algorithmic-thinking'],
  ),
  _path(
    id: 'path-math-logic',
    title: 'Parcours Logique mathématique',
    description: 'Vérifie des raisonnements simples étape par étape.',
    domainId: 'mathematiques',
    estimatedDuration: const Duration(minutes: 45),
    courseIds: ['mathematical-logic'],
    moduleIds: ['module-mathematical-logic'],
  ),
  _path(
    id: 'path-technical-english',
    title: 'Parcours Anglais technique',
    description: 'Gagne en autonomie pour lire une documentation numérique.',
    domainId: 'langues',
    estimatedDuration: const Duration(minutes: 60),
    courseIds: ['technical-english'],
    moduleIds: ['module-technical-english'],
  ),
  _path(
    id: 'path-science-data',
    title: 'Parcours Données scientifiques',
    description:
        'Apprends à lire des mesures sans tirer de conclusions hâtives.',
    domainId: 'sciences',
    estimatedDuration: const Duration(minutes: 60),
    courseIds: ['scientific-data'],
    moduleIds: ['module-scientific-data'],
  ),
  _path(
    id: 'path-office-basics',
    title: 'Parcours Bureautique essentielle',
    description:
        'Organise des données et automatise un calcul dans un tableur.',
    domainId: 'bureautique',
    estimatedDuration: const Duration(minutes: 45),
    courseIds: ['spreadsheet-skills'],
    moduleIds: ['module-spreadsheet-skills'],
  ),
  _path(
    id: 'path-visual-design',
    title: 'Parcours Design graphique',
    description:
        'Compose des visuels plus lisibles avec quelques principes clés.',
    domainId: 'design-graphique',
    estimatedDuration: const Duration(minutes: 60),
    courseIds: ['visual-design-basics'],
    moduleIds: ['module-visual-design'],
  ),
]);

LearningPathModel _path({
  required String id,
  required String title,
  required String description,
  required String domainId,
  required Duration estimatedDuration,
  required List<String> courseIds,
  required List<String> moduleIds,
}) {
  final pathLessonIds = mockModules
      .where((module) => moduleIds.contains(module.id))
      .expand((module) => module.lessonIds)
      .toSet();
  final lessons = mockLessons
      .where((lesson) => pathLessonIds.contains(lesson.id))
      .toList();
  final completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
  final progress = lessons.isEmpty
      ? 0.0
      : completedLessons / lessons.length * 100;

  return LearningPathModel(
    id: id,
    title: title,
    description: description,
    domainId: domainId,
    level: DifficultyLevel.beginner,
    estimatedDuration: estimatedDuration,
    courseIds: courseIds,
    moduleIds: moduleIds,
    progressPercentage: progress,
    isCompleted: lessons.isNotEmpty && completedLessons == lessons.length,
  );
}
