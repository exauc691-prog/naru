import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../shared/models/enums/learning_activity_type.dart';
import '../../../shared/models/learning_activity_model.dart';
import 'home_empty_state.dart';

class RecentActivitySection extends ConsumerWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Activité récente',
          trailing: TextButton(
            onPressed: () => context.go(AppRoutes.progress),
            child: const Text('Voir tout'),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        activities.when(
          loading: () => const SizedBox(
            height: 96,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Chargement de votre activité',
              ),
            ),
          ),
          error: (_, _) => AppErrorView(
            message: 'Votre activité récente ne peut pas être chargée.',
            onRetry: () => ref.invalidate(recentActivitiesProvider),
          ),
          data: (items) {
            final recent = items.take(3).toList();
            if (recent.isEmpty) {
              return const HomeEmptyState(
                icon: Icons.history_rounded,
                title: 'Aucune activité récente',
                message: 'Votre progression apparaîtra ici au fil du temps.',
              );
            }

            return Column(
              children: [
                for (var index = 0; index < recent.length; index++) ...[
                  _ActivityTile(activity: recent[index]),
                  if (index < recent.length - 1)
                    const Divider(height: 1, indent: 48),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final LearningActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final route = _routeFor(activity);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 36,
      horizontalTitleGap: AppSpacing.small,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: palette.surfaceMuted,
        foregroundColor: palette.primary,
        child: Icon(_iconFor(activity.activityType), size: 18),
      ),
      title: Text(
        activity.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        activity.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: palette.textSecondary),
      ),
      trailing: route == null
          ? null
          : const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: route == null ? null : () => context.go(route),
    );
  }

  static String? _routeFor(LearningActivityModel activity) =>
      switch (activity.activityType) {
        LearningActivityType.lessonCompleted =>
          activity.relatedId == null
              ? null
              : AppRoutes.lessonDetailsPath(activity.relatedId!),
        LearningActivityType.courseStarted ||
        LearningActivityType.courseCompleted =>
          activity.relatedId == null
              ? null
              : AppRoutes.courseDetailsPath(activity.relatedId!),
        LearningActivityType.exerciseCompleted => AppRoutes.practice,
        LearningActivityType.goalCompleted => AppRoutes.progress,
        LearningActivityType.achievementUnlocked => AppRoutes.achievements,
      };

  static IconData _iconFor(LearningActivityType type) => switch (type) {
    LearningActivityType.courseStarted => Icons.play_circle_outline_rounded,
    LearningActivityType.courseCompleted => Icons.school_outlined,
    LearningActivityType.lessonCompleted => Icons.check_circle_outline_rounded,
    LearningActivityType.exerciseCompleted => Icons.edit_note_rounded,
    LearningActivityType.goalCompleted => Icons.flag_outlined,
    LearningActivityType.achievementUnlocked => Icons.emoji_events_outlined,
  };
}
