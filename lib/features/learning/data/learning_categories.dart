import 'package:flutter/material.dart';

class LearningCategoryDefinition {
  const LearningCategoryDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.domainIds = const [],
    this.isAll = false,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> domainIds;
  final bool isAll;
}

const learningCategories = [
  LearningCategoryDefinition(
    id: 'all',
    name: 'Tout',
    description: 'Tous les cours disponibles.',
    icon: Icons.grid_view_rounded,
    isAll: true,
  ),
  LearningCategoryDefinition(
    id: 'informatique',
    name: 'Informatique',
    description: 'Les fondamentaux du numérique.',
    icon: Icons.computer_outlined,
    domainIds: [
      'programmation',
      'developpement-web',
      'developpement-mobile',
      'intelligence-artificielle',
      'cybersecurite',
      'bases-de-donnees',
      'algorithmique',
    ],
  ),
  LearningCategoryDefinition(
    id: 'programmation',
    name: 'Programmation',
    description: 'Apprends à concevoir des solutions.',
    icon: Icons.code_rounded,
    domainIds: ['programmation', 'algorithmique'],
  ),
  LearningCategoryDefinition(
    id: 'intelligence-artificielle',
    name: 'Intelligence artificielle',
    description: 'Comprends les données et les modèles.',
    icon: Icons.psychology_outlined,
    domainIds: ['intelligence-artificielle'],
  ),
  LearningCategoryDefinition(
    id: 'mathematiques',
    name: 'Mathématiques',
    description: 'Développe ton raisonnement logique.',
    icon: Icons.calculate_outlined,
    domainIds: ['mathematiques'],
  ),
  LearningCategoryDefinition(
    id: 'sciences',
    name: 'Sciences',
    description: 'Explore les méthodes scientifiques.',
    icon: Icons.science_outlined,
    domainIds: ['sciences'],
  ),
  LearningCategoryDefinition(
    id: 'langues',
    name: 'Langues',
    description: 'Progresse dans la compréhension des langues.',
    icon: Icons.translate_rounded,
    domainIds: ['langues'],
  ),
  LearningCategoryDefinition(
    id: 'entrepreneuriat',
    name: 'Entrepreneuriat',
    description: 'Projets et création d’activité.',
    icon: Icons.lightbulb_outline_rounded,
  ),
  LearningCategoryDefinition(
    id: 'developpement-personnel',
    name: 'Développement personnel',
    description: 'Méthodes pour mieux apprendre et s’organiser.',
    icon: Icons.self_improvement_rounded,
  ),
  LearningCategoryDefinition(
    id: 'economie',
    name: 'Économie',
    description: 'Notions économiques et gestion des ressources.',
    icon: Icons.trending_up_rounded,
  ),
  LearningCategoryDefinition(
    id: 'technologie',
    name: 'Technologie',
    description: 'Outils et usages numériques.',
    icon: Icons.devices_other_outlined,
    domainIds: [
      'developpement-web',
      'developpement-mobile',
      'intelligence-artificielle',
      'cybersecurite',
      'bases-de-donnees',
      'bureautique',
      'design-graphique',
    ],
  ),
];

LearningCategoryDefinition? learningCategoryById(String? id) {
  if (id == null) return null;
  for (final category in learningCategories) {
    if (category.id == id) return category;
  }
  return null;
}
