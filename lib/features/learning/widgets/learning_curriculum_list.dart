import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/lesson_model.dart';
import '../providers/learning_providers.dart';
import 'learning_formatters.dart';

class LearningCurriculumList extends StatelessWidget {
  const LearningCurriculumList({
    super.key,
    required this.curriculum,
    required this.onLessonTap,
  });

  final List<LearningModuleContent> curriculum;
  final ValueChanged<LessonModel> onLessonTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);

    if (curriculum.isEmpty) {
      return Text(
        'Le programme détaillé sera bientôt disponible.',
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: palette.textSecondary),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < curriculum.length; index++) ...[
          ExpansionTile(
            initiallyExpanded: index == 0,
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(left: AppSpacing.medium),
            title: Text(
              curriculum[index].module.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              curriculum[index].module.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              for (final lesson in curriculum[index].lessons)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    lesson.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.play_circle_outline_rounded,
                    color: lesson.isCompleted
                        ? palette.success
                        : palette.textSecondary,
                    size: 20,
                  ),
                  title: Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    '${durationLabel(lesson.estimatedDuration)} · '
                    '${lesson.description}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onLessonTap(lesson),
                ),
            ],
          ),
          if (index < curriculum.length - 1)
            const Divider(height: AppSpacing.medium),
        ],
      ],
    );
  }
}
