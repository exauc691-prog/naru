import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/personal_learning_models.dart';
import '../../providers/personal_learning_providers.dart';

class GoalSetupScreen extends ConsumerStatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  ConsumerState<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends ConsumerState<GoalSetupScreen> {
  final _titleController = TextEditingController();
  String _category = 'Programmation';
  PersonalLearningLevel _level = PersonalLearningLevel.beginner;
  int _dailyMinutes = 30;
  int _deadlineMonths = 3;

  static const _categories = [
    'Programmation',
    'IA',
    'Maths',
    'Sciences',
    'Langues',
    'Entrepreneuriat',
    'Technologie',
    'Autre',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Décrivez votre objectif.')),
      );
      return;
    }
    final now = DateTime.now();
    final goal = PersonalLearningGoal(
      id: 'goal-${now.microsecondsSinceEpoch}',
      title: title,
      category: _category,
      level: _level,
      dailyMinutes: _dailyMinutes,
      targetDate: now.add(Duration(days: _deadlineMonths * 30)),
    );
    await ref.read(personalLearningGoalsProvider.notifier).save(goal);
    if (!mounted) return;
    context.go(AppRoutes.studyPlan);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Créer un objectif')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              Text(
                'Que souhaitez-vous apprendre ?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.medium),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Par exemple : apprendre Flutter',
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              Text('Catégorie',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  for (final category in _categories)
                    ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) =>
                          setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
              Text('Votre niveau',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.small),
              SegmentedButton<PersonalLearningLevel>(
                segments: const [
                  ButtonSegment(
                    value: PersonalLearningLevel.beginner,
                    label: Text('Débutant'),
                  ),
                  ButtonSegment(
                    value: PersonalLearningLevel.intermediate,
                    label: Text('Intermédiaire'),
                  ),
                  ButtonSegment(
                    value: PersonalLearningLevel.advanced,
                    label: Text('Avancé'),
                  ),
                ],
                selected: {_level},
                onSelectionChanged: (values) =>
                    setState(() => _level = values.first),
              ),
              const SizedBox(height: AppSpacing.large),
              Text('Temps disponible',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.small),
              DropdownButtonFormField<int>(
                initialValue: _dailyMinutes,
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 min/jour')),
                  DropdownMenuItem(value: 30, child: Text('30 min/jour')),
                  DropdownMenuItem(value: 60, child: Text('1 h/jour')),
                  DropdownMenuItem(value: 120, child: Text('2 h/jour')),
                ],
                onChanged: (value) =>
                    setState(() => _dailyMinutes = value ?? 30),
              ),
              const SizedBox(height: AppSpacing.large),
              Text('Échéance',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.small),
              DropdownButtonFormField<int>(
                initialValue: _deadlineMonths,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 mois')),
                  DropdownMenuItem(value: 3, child: Text('3 mois')),
                  DropdownMenuItem(value: 6, child: Text('6 mois')),
                  DropdownMenuItem(value: 12, child: Text('1 an')),
                ],
                onChanged: (value) =>
                    setState(() => _deadlineMonths = value ?? 3),
              ),
              const SizedBox(height: AppSpacing.large),
              FilledButton(
                onPressed: _create,
                child: const Text('Préparer mon parcours'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
