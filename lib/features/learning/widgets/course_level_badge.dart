import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/enums/difficulty_level.dart';
import 'learning_formatters.dart';

class CourseLevelBadge extends StatelessWidget {
  const CourseLevelBadge({super.key, required this.level});

  final DifficultyLevel level;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final label = difficultyLabel(level);

    return Semantics(
      label: 'Niveau $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: AppSpacing.verySmall,
        ),
        decoration: BoxDecoration(
          color: palette.primaryContainer,
          borderRadius: AppRadius.smallBorderRadius,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: palette.onPrimaryContainer),
        ),
      ),
    );
  }
}
