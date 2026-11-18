import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../shared/models/learning_path_model.dart';
import 'course_level_badge.dart';
import 'learning_formatters.dart';

class LearningPathCard extends StatelessWidget {
  const LearningPathCard({
    super.key,
    required this.path,
    required this.domainName,
    required this.onTap,
  });

  final LearningPathModel path;
  final String domainName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final progressPercent = path.progressPercentage.clamp(0.0, 100.0).round();
    final hasProgress = progressPercent > 0 || path.isCompleted;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: AppRadius.mediumBorderRadius,
                ),
                child: Icon(
                  Icons.route_outlined,
                  color: palette.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domainName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: palette.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.verySmall),
                    Text(
                      path.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: palette.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            path.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CourseLevelBadge(level: path.level),
              Text(
                durationLabel(path.estimatedDuration),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: palette.textSecondary),
              ),
              if (path.moduleIds.isNotEmpty)
                Text(
                  '${path.moduleIds.length} modules',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.textSecondary),
                ),
              Text(
                '${path.courseIds.length} cours',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: palette.textSecondary),
              ),
            ],
          ),
          if (hasProgress) ...[
            const SizedBox(height: AppSpacing.medium),
            Row(
              children: [
                Expanded(
                  child: AppProgressBar(
                    value: progressPercent / 100,
                    height: 6,
                    semanticsLabel: 'Progression du parcours ${path.title}',
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  '$progressPercent %',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: palette.textSecondary),
                ),
              ],
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                hasProgress ? 'Continuer le parcours' : 'Découvrir le parcours',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
