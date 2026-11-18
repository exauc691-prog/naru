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

class CourseListItem extends StatelessWidget {
  const CourseListItem({
    super.key,
    required this.course,
    required this.domainName,
    required this.onTap,
  });

  final CourseModel course;
  final String domainName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final hasProgress = course.completedLessons > 0 && course.lessonsCount > 0;
    final progress = course.lessonsCount <= 0
        ? 0.0
        : (course.completedLessons / course.lessonsCount)
              .clamp(0.0, 1.0)
              .toDouble();

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.primaryContainer,
                  borderRadius: AppRadius.mediumBorderRadius,
                ),
                child: Icon(
                  learningDomainIcon(course.domainId),
                  color: palette.onPrimaryContainer,
                  size: 21,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                          Text(
                            'Nouveau',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: palette.primary),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.verySmall),
                    Text(
                      course.title,
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
            course.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
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
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: AppSpacing.medium,
            runSpacing: AppSpacing.verySmall,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                course.isPremium ? 'Premium' : 'Gratuit',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: course.isPremium
                      ? palette.textSecondary
                      : palette.primary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 16, color: palette.primary),
                  const SizedBox(width: AppSpacing.verySmall),
                  Text(course.rating.toStringAsFixed(1)),
                ],
              ),
              Text(
                course.format.label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: palette.textSecondary),
              ),
              Text(
                learnerCountLabel(course.enrolledStudents),
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
    );
  }
}
