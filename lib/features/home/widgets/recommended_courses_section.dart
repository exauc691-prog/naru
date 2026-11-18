import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/enums/difficulty_level.dart';
import '../../learning/providers/learning_providers.dart';
import 'home_empty_state.dart';

class RecommendedCoursesSection extends ConsumerWidget {
  const RecommendedCoursesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(recommendedCoursesProvider);
    final domains = ref.watch(learningDomainsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Pour vous',
          trailing: TextButton(
            onPressed: () => context.go(AppRoutes.learning),
            child: const Text('Voir tout'),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        recommendations.when(
          loading: () => const SizedBox(
            height: 190,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Chargement des cours recommandés',
              ),
            ),
          ),
          error: (_, _) => AppErrorView(
            message: 'Les cours recommandés ne peuvent pas être chargés.',
            onRetry: () => ref.invalidate(recommendedCoursesProvider),
          ),
          data: (courses) => domains.when(
            loading: () => const SizedBox(
              height: 190,
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Chargement des domaines',
                ),
              ),
            ),
            error: (_, _) => AppErrorView(
              message: 'Les domaines des cours ne peuvent pas être chargés.',
              onRetry: () => ref.invalidate(learningDomainsProvider),
            ),
            data: (domainList) {
              final recommended = courses.take(4).toList();
              if (recommended.isEmpty) {
                return const HomeEmptyState(
                  icon: Icons.auto_stories_outlined,
                  title: 'Aucun cours recommandé',
                  message: 'De nouvelles suggestions apparaîtront ici.',
                );
              }

              final domainNames = {
                for (final domain in domainList) domain.id: domain.name,
              };

              return SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.medium),
                  itemBuilder: (context, index) {
                    final course = recommended[index];
                    return _RecommendedCourseCard(
                      course: course,
                      domainName:
                          domainNames[course.domainId] ?? course.domainId,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendedCourseCard extends StatelessWidget {
  const _RecommendedCourseCard({
    required this.course,
    required this.domainName,
  });

  final CourseModel course;
  final String domainName;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);

    return SizedBox(
      width: 248,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.medium),
        onTap: () => context.push(AppRoutes.courseDetailsPath(course.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: palette.primaryContainer,
                    borderRadius: AppRadius.mediumBorderRadius,
                  ),
                  child: Icon(
                    _courseIcon(course.domainId),
                    color: palette.onPrimaryContainer,
                    size: 19,
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    domainName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: palette.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _difficultyLabel(course.difficulty),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: palette.textSecondary),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  _durationLabel(course.estimatedDuration),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: palette.textSecondary),
                ),
                const SizedBox(width: AppSpacing.verySmall),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: palette.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _courseIcon(String domainId) {
    if (domainId.contains('mobile')) return Icons.phone_android_rounded;
    if (domainId.contains('artificielle')) return Icons.auto_awesome_rounded;
    if (domainId.contains('web')) return Icons.web_rounded;
    if (domainId.contains('donnees')) return Icons.storage_rounded;
    if (domainId.contains('cyber')) return Icons.shield_outlined;
    return Icons.code_rounded;
  }

  static String _difficultyLabel(DifficultyLevel difficulty) =>
      switch (difficulty) {
        DifficultyLevel.beginner => 'Débutant',
        DifficultyLevel.intermediate => 'Intermédiaire',
        DifficultyLevel.advanced => 'Avancé',
      };

  static String _durationLabel(Duration duration) {
    if (duration.inHours == 0) return '${duration.inMinutes} min';
    final remainingMinutes = duration.inMinutes % 60;
    return remainingMinutes == 0
        ? '${duration.inHours} h'
        : '${duration.inHours} h $remainingMinutes min';
  }
}
