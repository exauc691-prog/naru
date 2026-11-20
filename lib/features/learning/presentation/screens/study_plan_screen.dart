import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../providers/personal_learning_providers.dart';

class StudyPlanScreen extends ConsumerWidget {
  const StudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(personalLearningGoalsProvider);
    final sessions = ref.watch(studySessionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon plan d’étude'),
        actions: [
          IconButton(
            tooltip: 'Modifier mon objectif',
            onPressed: () => context.push(AppRoutes.goalSetup),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
              children: [
                goals.when(
                  data: (items) => items.isEmpty
                      ? AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Construisez votre premier parcours',
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.small),
                              const Text(
                                'Définissez un objectif et organise votre apprentissage.',
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              FilledButton(
                                onPressed: () => context.push(AppRoutes.goalSetup),
                                child: const Text('Créer un objectif'),
                              ),
                            ],
                          ),
                        )
                      : AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(items.first.title,
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.verySmall),
                              Text(
                                '${items.first.category} · ${items.first.dailyMinutes} min/jour',
                              ),
                            ],
                          ),
                        ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) =>
                      const Text('Votre objectif ne peut pas être chargé.'),
                ),
                const SizedBox(height: AppSpacing.large),
                Text('Cette semaine',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.small),
                sessions.when(
                  data: (items) => Column(
                    children: [
                      for (final session in items)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.small,
                          ),
                          child: AppCard(
                            onTap: () => ref
                                .read(studySessionsProvider.notifier)
                                .toggle(session.id),
                            child: Row(
                              children: [
                                Icon(
                                  session.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                ),
                                const SizedBox(width: AppSpacing.medium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(session.day),
                                      Text(session.title),
                                    ],
                                  ),
                                ),
                                Text('${session.durationMinutes} min'),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.medium),
                      FilledButton.icon(
                        onPressed: () => context.push(
                          AppRoutes.assistant,
                        ),
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('Demander de l’aide à Naru AI'),
                      ),
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) =>
                      const Text('Le plan d’étude ne peut pas être chargé.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
