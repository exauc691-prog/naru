import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../shared/models/course_model.dart';
import '../data/learning_categories.dart';
import '../providers/learning_providers.dart';
import 'learning_category_card.dart';

class LearningCategorySection extends ConsumerWidget {
  const LearningCategorySection({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);

    return courses.when(
      loading: () => const SizedBox(
        height: 168,
        child: Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Chargement des catégories',
          ),
        ),
      ),
      error: (_, _) => AppErrorView(
        message: 'Les catégories ne peuvent pas être chargées.',
        onRetry: () => ref.invalidate(coursesProvider),
      ),
      data: (items) => SizedBox(
        height: 184,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: learningCategories.length,
          separatorBuilder: (_, _) =>
              const SizedBox(width: AppSpacing.medium),
          itemBuilder: (context, index) {
            final category = learningCategories[index];
            return LearningCategoryCard(
              category: category,
              courseCount: _courseCount(category, items),
              onTap: () => onSelected(category.id),
            );
          },
        ),
      ),
    );
  }

  int _courseCount(
    LearningCategoryDefinition category,
    List<CourseModel> courses,
  ) {
    if (category.isAll) return courses.length;
    return courses
        .where((course) => category.domainIds.contains(course.domainId))
        .length;
  }
}
