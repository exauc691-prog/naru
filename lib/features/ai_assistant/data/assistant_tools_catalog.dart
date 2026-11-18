import 'package:flutter/material.dart';

import '../../subscription/models/subscription_plan.dart';
import '../models/assistant_mode.dart';

class AssistantToolDefinition {
  const AssistantToolDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.mode,
    required this.promptHint,
    this.requiredFeature,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final AssistantMode mode;
  final String promptHint;
  final SubscriptionFeature? requiredFeature;
}

const assistantTools = <AssistantToolDefinition>[
  AssistantToolDefinition(
    id: 'summary',
    title: 'Générateur de résumés',
    description: 'Préparez une structure de résumé à partir de vos notes.',
    category: 'Études',
    icon: Icons.summarize_outlined,
    mode: AssistantMode.writing,
    promptHint: 'Collez les notes à résumer…',
  ),
  AssistantToolDefinition(
    id: 'revision-cards',
    title: 'Fiches de révision',
    description: 'Organisez un sujet en questions et notions clés.',
    category: 'Études',
    icon: Icons.style_outlined,
    mode: AssistantMode.learn,
    promptHint: 'Quel sujet souhaitez-vous réviser ?',
  ),
  AssistantToolDefinition(
    id: 'quiz',
    title: 'Créateur de quiz',
    description: 'Préparez un exemple de quiz pour vérifier vos acquis.',
    category: 'Études',
    icon: Icons.quiz_outlined,
    mode: AssistantMode.learn,
    promptHint: 'Indiquez le thème et le niveau du quiz…',
  ),
  AssistantToolDefinition(
    id: 'study-plan',
    title: 'Programme d’étude',
    description: 'Découpez un objectif d’apprentissage en étapes.',
    category: 'Études',
    icon: Icons.event_note_outlined,
    mode: AssistantMode.organization,
    promptHint: 'Quel sujet, objectif et rythme envisager ?',
    requiredFeature: SubscriptionFeature.extendedAssistant,
  ),
  AssistantToolDefinition(
    id: 'programming',
    title: 'Assistant de programmation',
    description: 'Explorez un concept et des exemples de code.',
    category: 'Code et langues',
    icon: Icons.code_rounded,
    mode: AssistantMode.programming,
    promptHint: 'Décrivez le concept ou le code à explorer…',
    requiredFeature: SubscriptionFeature.assistantProgrammingTools,
  ),
  AssistantToolDefinition(
    id: 'outline',
    title: 'Générateur de plans',
    description: 'Structurez une présentation, un texte ou un projet.',
    category: 'Écriture et organisation',
    icon: Icons.account_tree_outlined,
    mode: AssistantMode.organization,
    promptHint: 'Quel sujet souhaitez-vous structurer ?',
  ),
  AssistantToolDefinition(
    id: 'translator',
    title: 'Traducteur',
    description: 'Préparez le contexte et les langues d’une traduction.',
    category: 'Code et langues',
    icon: Icons.translate_rounded,
    mode: AssistantMode.translation,
    promptHint: 'Saisissez le texte et les langues souhaitées…',
  ),
  AssistantToolDefinition(
    id: 'proofreader',
    title: 'Correcteur',
    description: 'Préparez la révision d’un texte et de son registre.',
    category: 'Écriture et organisation',
    icon: Icons.spellcheck_rounded,
    mode: AssistantMode.writing,
    promptHint: 'Collez le texte à relire…',
  ),
  AssistantToolDefinition(
    id: 'reading-helper',
    title: 'Assistant de lecture',
    description: 'Organisez vos questions et repères de lecture.',
    category: 'Études',
    icon: Icons.menu_book_outlined,
    mode: AssistantMode.learn,
    promptHint: 'Indiquez un livre, un thème ou une question…',
  ),
  AssistantToolDefinition(
    id: 'project-organizer',
    title: 'Organisateur de projets',
    description: 'Transformez une idée en étapes et priorités.',
    category: 'Écriture et organisation',
    icon: Icons.checklist_rounded,
    mode: AssistantMode.organization,
    promptHint: 'Décrivez votre idée ou projet…',
    requiredFeature: SubscriptionFeature.assistantAdvancedGeneration,
  ),
];
