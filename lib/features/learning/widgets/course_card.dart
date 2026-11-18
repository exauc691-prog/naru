import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../shared/models/course_model.dart';
import 'course_level_badge.dart';
import 'learning_domain_icon.dart';
import 'learning_formatters.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.domainName,
    required this.onTap,
    this.width = 260,
  });

  final CourseModel course;
  final String domainName;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final hasProgress = course.completedLessons > 0 && course.lessonsCount > 0;
    final progress = course.lessonsCount <= 0
        ? 0.0
        : (course.completedLessons / course.lessonsCount)
              .clamp(0.0, 1.0)
              .toDouble();

    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: palette.primaryContainer,
                    borderRadius: AppRadius.mediumBorderRadius,
                  ),
                  child: Icon(
                    learningDomainIcon(course.domainId),
                    color: palette.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    domainName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: palette.textSecondary),
                  ),
                ),
                if (course.isNew) ...[
                  const SizedBox(width: AppSpacing.small),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.surfaceMuted,
                      borderRadius: AppRadius.smallBorderRadius,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.small,
                        vertical: AppSpacing.verySmall,
                      ),
                      child: Text(
                        'Nouveau',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.verySmall),
            Text(
              course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: palette.textSecondary),
            ),
            const Spacer(),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.verySmall,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CourseLevelBadge(level: course.difficulty),
                Text(
                  durationLabel(course.estimatedDuration),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.textSecondary),
                ),
                Text(
                  '${course.lessonsCount} leçons',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.textSecondary),
                ),
              ],
            ),
            if (hasProgress) ...[
              const SizedBox(height: AppSpacing.small),
              Row(
                children: [
                  Expanded(
                    child: AppProgressBar(
                      value: progress,
                      height: 6,
                      semanticsLabel: 'Progression de ${course.title}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Text(
                    '${course.completedLessons}/${course.lessonsCount}',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: palette.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
