import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/section_title.dart';
import 'home_empty_state.dart';

class DailyGoalSection extends ConsumerWidget {
  const DailyGoalSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(dailyGoalProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Votre objectif du jour'),
        const SizedBox(height: AppSpacing.medium),
        goal.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Chargement de votre objectif',
              ),
            ),
          ),
          error: (_, _) => AppErrorView(
            message: 'Votre objectif quotidien ne peut pas être chargé.',
            onRetry: () => ref.invalidate(dailyGoalProvider),
          ),
          data: (value) {
            if (value == null || value.targetMinutes <= 0) {
              return const HomeEmptyState(
                icon: Icons.flag_outlined,
                title: 'Aucun objectif défini',
                message: 'Votre objectif quotidien apparaîtra ici.',
              );
            }

            final progress = (value.completedMinutes / value.targetMinutes)
                .clamp(0.0, 1.0)
                .toDouble();
            final remaining = (value.targetMinutes - value.completedMinutes)
                .clamp(0, value.targetMinutes)
                .toInt();
            final palette = AppColors.of(context);

            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.small,
                          runSpacing: AppSpacing.verySmall,
                          children: [
                            Text(
                              '${value.completedMinutes} min',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              'sur ${value.targetMinutes} min',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.small),
                      Icon(
                        remaining == 0
                            ? Icons.check_circle_outline_rounded
                            : Icons.schedule_rounded,
                        color: remaining == 0
                            ? palette.success
                            : palette.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  AppProgressBar(
                    value: progress,
                    semanticsLabel: 'Progression de l’objectif quotidien',
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    remaining == 0
                        ? 'Objectif atteint aujourd’hui'
                        : 'Encore $remaining min pour atteindre votre objectif',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: palette.textSecondary),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
