import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../practice/providers/practice_providers.dart';
import '../providers/assessment_providers.dart';

class AssessmentHomeScreen extends ConsumerWidget {
  const AssessmentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider);
    final attempts = ref.watch(assessmentAttemptsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercices et évaluations'),
        actions: [
          IconButton(
            tooltip: 'Historique des évaluations',
            onPressed: () => context.push(AppRoutes.assessmentHistory),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: 'Mes compétences',
            onPressed: () => context.push(AppRoutes.competencies),
            icon: const Icon(Icons.insights_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: exercises.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Chargement des évaluations',
                ),
              ),
              error: (_, _) => AppErrorView(
                message: 'Les exercices ne peuvent pas être chargés.',
                onRetry: () => ref.invalidate(exercisesProvider),
              ),
              data: (items) => ListView(
                padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
                children: [
                  const SectionTitle(title: 'À faire'),
                  const SizedBox(height: AppSpacing.small),
                  if (items.isEmpty)
                    const AppEmptyState(
                      icon: Icons.quiz_outlined,
                      title: 'Aucune activité disponible',
                      description:
                          'De nouveaux exercices apparaîtront ici.',
                    )
                  else
                    for (final exercise in items.take(8))
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: AppCard(
                          onTap: () => context.push(
                            AppRoutes.exerciseDetailsPath(exercise.id),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.quiz_outlined),
                              const SizedBox(width: AppSpacing.medium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(exercise.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    Text(
                                      '${_exerciseTypeLabel(exercise.exerciseType)} · '
                                      '${exercise.points} points',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.large),
                  const SectionTitle(title: 'Mes résultats'),
                  const SizedBox(height: AppSpacing.small),
                  attempts.when(
                    data: (values) => values.isEmpty
                        ? const Text(
                            'Vos premiers résultats apparaîtront ici après un quiz.',
                          )
                        : Column(
                            children: [
                              for (final attempt in values.take(3))
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.small,
                                  ),
                                  child: AppCard(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(attempt.assessmentTitle),
                                        ),
                                        Text('${attempt.percentage} %'),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) =>
                        const Text('Les résultats ne peuvent pas être chargés.'),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  const SectionTitle(title: 'Révision'),
                  const SizedBox(height: AppSpacing.small),
                  AppCard(
                    onTap: () => context.push(
                      AppRoutes.exerciseDetailsPath(
                        items.isEmpty
                            ? 'exercise-dart-introduction'
                            : items.last.id,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.refresh_rounded),
                        SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Text(
                            'Revoir une activité pour consolider vos acquis',
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _exerciseTypeLabel(dynamic type) => switch (type.name) {
    'multipleChoice' => 'Choix unique',
    'trueFalse' => 'Vrai ou faux',
    'shortAnswer' => 'Réponse courte',
    'codingChallenge' => 'Programmation',
    _ => 'Exercice',
  };
}
