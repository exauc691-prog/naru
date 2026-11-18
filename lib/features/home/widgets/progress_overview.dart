import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';

class ProgressOverview extends ConsumerWidget {
  const ProgressOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(overallProgressProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Ma progression',
          trailing: TextButton(
            onPressed: () => context.go(AppRoutes.progress),
            child: const Text('Voir tout'),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        progress.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => AppErrorView(
            message: 'Votre progression ne peut pas être chargée.',
            onRetry: () => ref.invalidate(overallProgressProvider),
          ),
          data: (value) => AppCard(
            child: Wrap(
              spacing: AppSpacing.large,
              runSpacing: AppSpacing.medium,
              children: [
                _Stat(label: 'Cours', value: '${value.completedCourses}'),
                _Stat(label: 'Leçons', value: '${value.completedLessons}'),
                _Stat(
                  label: 'Temps',
                  value: _duration(value.totalLearningMinutes),
                ),
                _Stat(label: 'Exercices', value: '${value.completedExercises}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _duration(int minutes) {
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return hours == 0 ? '$rest min' : '${hours}h ${rest.toString().padLeft(2, '0')}';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 112,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
