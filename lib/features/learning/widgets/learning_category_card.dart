import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../data/learning_categories.dart';

class LearningCategoryCard extends StatelessWidget {
  const LearningCategoryCard({
    super.key,
    required this.category,
    required this.courseCount,
    required this.onTap,
  });

  final LearningCategoryDefinition category;
  final int courseCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);

    return SizedBox(
      width: 190,
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: palette.primaryContainer,
                borderRadius: AppRadius.mediumBorderRadius,
              ),
              child: Icon(
                category.icon,
                color: palette.onPrimaryContainer,
                size: 21,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.verySmall),
            Expanded(
              child: Text(
                category.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.verySmall),
            Text(
              '$courseCount cours',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
