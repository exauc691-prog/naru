import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../shared/models/course_model.dart';
import 'learning_domain_icon.dart';

class InProgressCourseCard extends StatelessWidget {
  const InProgressCourseCard({
    super.key,
    required this.course,
    required this.domainName,
    required this.onContinue,
  });

  final CourseModel course;
  final String domainName;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final progress = course.lessonsCount <= 0
        ? 0.0
        : (course.completedLessons / course.lessonsCount)
              .clamp(0.0, 1.0)
              .toDouble();
    final percentage = (progress * 100).round();

    return SizedBox(
      width: 270,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  learningDomainIcon(course.domainId),
                  color: palette.primary,
                  size: 19,
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    domainName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.medium),
            AppProgressBar(
              value: progress,
              height: 6,
              semanticsLabel: 'Progression de ${course.title}',
            ),
            const SizedBox(height: AppSpacing.verySmall),
            Text(
              '${course.completedLessons} / ${course.lessonsCount} leçons terminées',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Continuer'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mediumBorderRadius,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
