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
import 'in_progress_course_card.dart';
import 'learning_empty_state.dart';

class ContinueLearningSection extends ConsumerWidget {
  const ContinueLearningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(inProgressCoursesProvider);
    final domains = ref.watch(learningDomainsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Continuer à apprendre'),
        const SizedBox(height: AppSpacing.small),
        courses.when(
          loading: () => const _ContinueLoading(),
          error: (_, _) => AppErrorView(
            message: 'La progression ne peut pas être chargée.',
            onRetry: () => ref.invalidate(inProgressCoursesProvider),
          ),
          data: (items) => domains.when(
            loading: () => const _ContinueLoading(),
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
      return LearningEmptyState(
        title: 'Aucun cours commencé',
        description:
            'Commence un cours pour retrouver ta progression ici.',
        icon: Icons.play_lesson_outlined,
        action: TextButton(
          onPressed: () => context.go(AppRoutes.courseCatalogPath()),
          child: const Text('Explorer les cours'),
        ),
      );
    }

    final domainNames = {for (final domain in domains) domain.id: domain.name};
    return SizedBox(
      height: 208,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.medium),
        itemBuilder: (context, index) {
          final course = courses[index];
          return InProgressCourseCard(
            course: course,
            domainName: domainNames[course.domainId] ?? course.domainId,
            onContinue: () =>
                context.push(AppRoutes.courseDetailsPath(course.id)),
          );
        },
      ),
    );
  }
}

class _ContinueLoading extends StatelessWidget {
  const _ContinueLoading();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 160,
    child: Center(
      child: CircularProgressIndicator(
        semanticsLabel: 'Chargement de la progression',
      ),
    ),
  );
}
