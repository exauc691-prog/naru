import '../models/enums/difficulty_level.dart';
import '../models/learning_domain_model.dart';

final mockDomains = List<LearningDomainModel>.unmodifiable([
  LearningDomainModel(
    id: 'programmation',
    name: 'Programmation',
    description: 'Apprends à concevoir des programmes, du premier algorithme au code structuré.',
    icon: 'code',
    colorCode: '#4F46E5',
    availableCoursesCount: 3,
    difficultyLevels: DifficultyLevel.values,
  ),
  LearningDomainModel(
    id: 'developpement-web',
    name: 'Développement Web',
    description:
        'Construis des pages accessibles et des expériences web interactives.',
    icon: 'web',
    colorCode: '#0F766E',
    availableCoursesCount: 3,
    difficultyLevels: DifficultyLevel.values,
  ),
  LearningDomainModel(
    id: 'developpement-mobile',
    name: 'Développement mobile',
    description: 'Découvre Flutter et les principes des applications mobiles.',
    icon: 'smartphone',
    colorCode: '#2563EB',
    availableCoursesCount: 4,
    difficultyLevels: DifficultyLevel.values,
  ),
  LearningDomainModel(
    id: 'intelligence-artificielle',
    name: 'Intelligence artificielle',
    description:
        'Explore les notions fondamentales et les usages responsables de l’IA.',
    icon: 'auto_awesome',
    colorCode: '#7C3AED',
    availableCoursesCount: 3,
    difficultyLevels: DifficultyLevel.values,
  ),
  LearningDomainModel(
    id: 'cybersecurite',
    name: 'Cybersécurité',
    description:
        'Adopte des réflexes simples pour protéger comptes et données.',
    icon: 'shield',
    colorCode: '#BE123C',
    availableCoursesCount: 1,
    difficultyLevels: const [
      DifficultyLevel.beginner,
      DifficultyLevel.intermediate,
    ],
  ),
  LearningDomainModel(
    id: 'bases-de-donnees',
    name: 'Bases de données',
    description: 'Organise les informations et interroge-les avec SQL.',
    icon: 'storage',
    colorCode: '#0369A1',
    availableCoursesCount: 2,
    difficultyLevels: DifficultyLevel.values,
  ),
  LearningDomainModel(
    id: 'algorithmique',
    name: 'Algorithmique',
    description: 'Décompose les problèmes en étapes logiques et vérifiables.',
    icon: 'account_tree',
    colorCode: '#9333EA',
    availableCoursesCount: 1,
    difficultyLevels: DifficultyLevel.values,
  ),
  LearningDomainModel(
    id: 'mathematiques',
    name: 'Mathématiques',
    description:
        'Renforce le raisonnement logique et les notions utiles au numérique.',
    icon: 'functions',
    colorCode: '#15803D',
    availableCoursesCount: 1,
    difficultyLevels: DifficultyLevel.values,
  ),
  LearningDomainModel(
    id: 'langues',
    name: 'Langues',
    description: 'Développe ton vocabulaire et ta compréhension des langues.',
    icon: 'translate',
    colorCode: '#C2410C',
    availableCoursesCount: 1,
    difficultyLevels: DifficultyLevel.values,
  ),
  LearningDomainModel(
    id: 'sciences',
    name: 'Sciences',
    description:
        'Découvre comment observer, analyser et interpréter des données.',
    icon: 'science',
    colorCode: '#0E7490',
    availableCoursesCount: 1,
    difficultyLevels: DifficultyLevel.values,
  ),
  LearningDomainModel(
    id: 'bureautique',
    name: 'Bureautique',
    description: 'Utilise les outils numériques du quotidien avec méthode.',
    icon: 'table_chart',
    colorCode: '#4D7C0F',
    availableCoursesCount: 1,
    difficultyLevels: const [
      DifficultyLevel.beginner,
      DifficultyLevel.intermediate,
    ],
  ),
  LearningDomainModel(
    id: 'design-graphique',
    name: 'Design graphique',
    description:
        'Compose des visuels clairs en travaillant couleurs et hiérarchie.',
    icon: 'palette',
    colorCode: '#DB2777',
    availableCoursesCount: 1,
    difficultyLevels: DifficultyLevel.values,
  ),
]);
