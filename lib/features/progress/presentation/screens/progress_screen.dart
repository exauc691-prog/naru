import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/section_title.dart';
import '../../providers/progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(overallProgressProvider);
    final skills = ref.watch(skillProgressProvider);
    final activities = ref.watch(recentActivitiesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progression'),
        actions: [
          IconButton(
            tooltip: 'Badges et récompenses',
            onPressed: () => context.push(AppRoutes.achievements),
            icon: const Icon(Icons.emoji_events_outlined),
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
                progress.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => AppErrorView(
                    message: 'Votre progression ne peut pas être chargée.',
                    onRetry: () => ref.invalidate(overallProgressProvider),
                  ),
                  data: (value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vue d’ensemble',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.small),
                      AppCard(
                        child: Wrap(
                          spacing: AppSpacing.large,
                          runSpacing: AppSpacing.medium,
                          children: [
                            _Stat(value.completedCourses, 'cours terminés'),
                            _Stat(value.completedLessons, 'leçons terminées'),
                            _Stat(value.completedExercises, 'exercices'),
                            _Stat(value.currentStreak, 'jours de suite'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text('${value.overallProgress.round()} %'),
                      const SizedBox(height: AppSpacing.small),
                      AppProgressBar(
                        value: value.overallProgress / 100,
                        semanticsLabel: 'Progression globale',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                const SectionTitle(title: 'Compétences'),
                const SizedBox(height: AppSpacing.small),
                skills.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) =>
                      const Text('Les compétences ne peuvent pas être chargées.'),
                  data: (items) => Column(
                    children: [
                      for (final skill in items)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.small,
                          ),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(skill.skillName)),
                                    Text('${skill.progressPercentage.round()} %'),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.small),
                                AppProgressBar(
                                  value: skill.progressPercentage / 100,
                                  semanticsLabel:
                                      'Progression de ${skill.skillName}',
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                const SectionTitle(title: 'Activité récente'),
                const SizedBox(height: AppSpacing.small),
                activities.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) =>
                      const Text('L’activité ne peut pas être chargée.'),
                  data: (items) => Column(
                    children: [
                      for (final activity in items.take(5))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.check_circle_outline_rounded,
                          ),
                          title: Text(activity.title),
                          subtitle: Text(activity.description),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 120,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
