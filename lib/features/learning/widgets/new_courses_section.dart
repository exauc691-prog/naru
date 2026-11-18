import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/learning_domain_model.dart';
import '../providers/learning_providers.dart';
import 'course_card.dart';
import 'learning_empty_state.dart';

class NewCoursesSection extends ConsumerWidget {
  const NewCoursesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(newCoursesProvider);
    final domains = ref.watch(learningDomainsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Nouveautés'),
        const SizedBox(height: AppSpacing.small),
        courses.when(
          loading: () => const _NewCoursesLoading(),
          error: (_, _) => AppErrorView(
            message: 'Les nouveautés ne peuvent pas être chargées.',
            onRetry: () => ref.invalidate(newCoursesProvider),
          ),
          data: (items) => domains.when(
            loading: () => const _NewCoursesLoading(),
            error: (_, _) => AppErrorView(
              message: 'Les domaines des cours ne peuvent pas être chargés.',
              onRetry: () => ref.invalidate(learningDomainsProvider),
            ),
            data: (domainItems) => _courseCards(
              context,
              items,
              domainItems,
            ),
          ),
        ),
      ],
    );
  }

  Widget _courseCards(
    BuildContext context,
    List<CourseModel> courses,
    List<LearningDomainModel> domains,
  ) {
    if (courses.isEmpty) {
      return const LearningEmptyState(
        title: 'Pas de nouveauté pour le moment',
        description: 'Les nouveaux cours apparaîtront ici.',
        icon: Icons.auto_stories_outlined,
      );
    }

    final domainNames = {for (final domain in domains) domain.id: domain.name};
    return SizedBox(
      height: 264,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.medium),
        itemBuilder: (context, index) {
          final course = courses[index];
          return CourseCard(
            course: course,
            domainName: domainNames[course.domainId] ?? course.domainId,
            onTap: () =>
                context.push(AppRoutes.courseDetailsPath(course.id)),
          );
        },
      ),
    );
  }
}

class _NewCoursesLoading extends StatelessWidget {
  const _NewCoursesLoading();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 180,
    child: Center(
      child: CircularProgressIndicator(
        semanticsLabel: 'Chargement des nouveautés',
      ),
    ),
  );
}
