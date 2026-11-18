import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/learning_domain_model.dart';
import '../../../shared/models/learning_path_model.dart';
import '../providers/learning_providers.dart';
import '../widgets/continue_learning_section.dart';
import '../widgets/course_card.dart';
import '../widgets/course_list_item.dart';
import '../widgets/learning_category_section.dart';
import '../widgets/learning_empty_state.dart';
import '../widgets/learning_header.dart';
import '../widgets/learning_search_bar.dart';
import '../widgets/learning_path_card.dart';
import '../widgets/new_courses_section.dart';

class LearningScreen extends ConsumerWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(learningDomainsProvider);
    final courses = ref.watch(recommendedCoursesProvider);
    final allCourses = ref.watch(coursesProvider);
    final paths = ref.watch(learningPathsProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.horizontalMargin,
                AppSpacing.large,
                AppSpacing.horizontalMargin,
                AppSpacing.veryLarge,
              ),
              children: [
                const LearningHeader(
                  title: 'Apprendre',
                  description:
                      'Découvrez, apprenez et développez vos compétences.',
                ),
                const SizedBox(height: AppSpacing.large),
                LearningSearchBar(
                  onSubmitted: (query) =>
                      context.go(AppRoutes.learningSearchPath(query)),
                ),
                const SizedBox(height: AppSpacing.section),
                SectionTitle(
                  title: 'Explorer les domaines',
                  trailing: TextButton(
                    onPressed: () => context.go(
                      AppRoutes.learningCategoryPath('all'),
                    ),
                    child: const Text('Tous les cours'),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                LearningCategorySection(
                  onSelected: (categoryId) => context.go(
                    AppRoutes.learningCategoryPath(categoryId),
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                SectionTitle(
                  title: 'Recommandé pour vous',
                  trailing: TextButton(
                    onPressed: () => context.go(AppRoutes.courseCatalogPath()),
                    child: const Text('Voir tout'),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                _recommendedCourses(context, ref, courses, domains),
                const SizedBox(height: AppSpacing.section),
                const ContinueLearningSection(),
                const SizedBox(height: AppSpacing.section),
                SectionTitle(
                  title: 'Parcours d’apprentissage',
                  trailing: TextButton(
                    onPressed: () => context.go(AppRoutes.learningPaths),
                    child: const Text('Voir tout'),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                _learningPaths(context, ref, paths, domains),
                const SizedBox(height: AppSpacing.section),
                const NewCoursesSection(),
                const SizedBox(height: AppSpacing.section),
                SectionTitle(
                  title: 'Explorer tous les cours',
                  trailing: TextButton(
                    onPressed: () => context.go(AppRoutes.courseCatalogPath()),
                    child: const Text('Catalogue'),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                _allCourses(context, ref, allCourses, domains),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recommendedCourses(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CourseModel>> courses,
    AsyncValue<List<LearningDomainModel>> domains,
  ) => courses.when(
    loading: () => const _SectionLoading(
      label: 'Chargement des cours recommandés',
      height: 208,
    ),
    error: (_, _) => AppErrorView(
      message: 'Les cours recommandés ne peuvent pas être chargés.',
      onRetry: () => ref.invalidate(recommendedCoursesProvider),
    ),
    data: (items) => domains.when(
      loading: () =>
          const _SectionLoading(label: 'Chargement des domaines', height: 208),
      error: (_, _) => AppErrorView(
        message: 'Les domaines des cours ne peuvent pas être chargés.',
        onRetry: () => ref.invalidate(learningDomainsProvider),
      ),
      data: (domainItems) {
        final recommendations = items.take(4).toList();
        if (recommendations.isEmpty) {
          return const LearningEmptyState(
            title: 'Aucun cours recommandé',
            description: 'De nouvelles suggestions apparaîtront ici.',
            icon: Icons.auto_stories_outlined,
          );
        }

        final domainNames = {
          for (final domain in domainItems) domain.id: domain.name,
        };

        return SizedBox(
          height: 264,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.medium),
            itemBuilder: (context, index) {
              final course = recommendations[index];
              return CourseCard(
                course: course,
                domainName: domainNames[course.domainId] ?? course.domainId,
                onTap: () =>
                    context.push(AppRoutes.courseDetailsPath(course.id)),
              );
            },
          ),
        );
      },
    ),
  );

  Widget _learningPaths(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LearningPathModel>> paths,
    AsyncValue<List<LearningDomainModel>> domains,
  ) => paths.when(
    loading: () =>
        const _SectionLoading(label: 'Chargement des parcours', height: 120),
    error: (_, _) => AppErrorView(
      message: 'Les parcours ne peuvent pas être chargés.',
      onRetry: () => ref.invalidate(learningPathsProvider),
    ),
    data: (items) => domains.when(
      loading: () =>
          const _SectionLoading(label: 'Chargement des domaines', height: 120),
      error: (_, _) => AppErrorView(
        message: 'Les domaines des parcours ne peuvent pas être chargés.',
        onRetry: () => ref.invalidate(learningDomainsProvider),
      ),
      data: (domainItems) {
        final featuredPaths = items.take(3).toList();
        if (featuredPaths.isEmpty) {
          return const LearningEmptyState(
            title: 'Aucun parcours disponible',
            description: 'Les parcours guidés apparaîtront ici.',
            icon: Icons.route_outlined,
          );
        }

        final domainNames = {
          for (final domain in domainItems) domain.id: domain.name,
        };
        return Column(
          children: [
            for (final path in featuredPaths) ...[
              LearningPathCard(
                path: path,
                domainName: domainNames[path.domainId] ?? path.domainId,
                onTap: () =>
                    context.push(AppRoutes.learningPathDetailsPath(path.id)),
              ),
              if (path != featuredPaths.last)
                const SizedBox(height: AppSpacing.medium),
            ],
          ],
        );
      },
    ),
  );

  Widget _allCourses(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CourseModel>> courses,
    AsyncValue<List<LearningDomainModel>> domains,
  ) => courses.when(
    loading: () => const _SectionLoading(
      label: 'Chargement du catalogue',
      height: 180,
    ),
    error: (_, _) => AppErrorView(
      message: 'Le catalogue ne peut pas être chargé.',
      onRetry: () => ref.invalidate(coursesProvider),
    ),
    data: (items) => domains.when(
      loading: () =>
          const _SectionLoading(label: 'Chargement des domaines', height: 180),
      error: (_, _) => AppErrorView(
        message: 'Les domaines des cours ne peuvent pas être chargés.',
        onRetry: () => ref.invalidate(learningDomainsProvider),
      ),
      data: (domainItems) {
        if (items.isEmpty) {
          return const LearningEmptyState(
            title: 'Aucun cours disponible',
            description: 'Les formations apparaîtront ici.',
          );
        }

        final previewCourses = items
            .where((course) => !course.isRecommended && !course.isNew)
            .take(3)
            .toList();
        final displayedCourses = previewCourses.isEmpty
            ? items.take(3).toList()
            : previewCourses;
        final domainNames = {
          for (final domain in domainItems) domain.id: domain.name,
        };

        return Column(
          children: [
            for (final course in displayedCourses) ...[
              CourseListItem(
                course: course,
                domainName: domainNames[course.domainId] ?? course.domainId,
                onTap: () =>
                    context.push(AppRoutes.courseDetailsPath(course.id)),
              ),
              if (course != displayedCourses.last)
                const SizedBox(height: AppSpacing.medium),
            ],
          ],
        );
      },
    ),
  );

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(learningDomainsProvider);
    ref.invalidate(recommendedCoursesProvider);
    ref.invalidate(coursesProvider);
    ref.invalidate(learningPathsProvider);
    ref.invalidate(inProgressCoursesProvider);
    ref.invalidate(newCoursesProvider);
    await Future.wait<Object?>([
      ref.read(learningDomainsProvider.future),
      ref.read(recommendedCoursesProvider.future),
      ref.read(coursesProvider.future),
      ref.read(learningPathsProvider.future),
      ref.read(inProgressCoursesProvider.future),
      ref.read(newCoursesProvider.future),
    ]);
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading({required this.label, required this.height});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(child: CircularProgressIndicator(semanticsLabel: label)),
  );
}
