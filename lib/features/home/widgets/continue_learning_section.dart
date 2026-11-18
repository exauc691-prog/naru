import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/section_title.dart';
import '../providers/home_providers.dart';
import 'home_empty_state.dart';

class ContinueLearningSection extends ConsumerWidget {
  const ContinueLearningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continuation = ref.watch(continueLearningProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Continuer à apprendre'),
        const SizedBox(height: AppSpacing.medium),
        continuation.when(
          loading: () => const SizedBox(
            height: 130,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Recherche de votre cours',
              ),
            ),
          ),
          error: (_, _) => AppErrorView(
            message: 'Votre apprentissage en cours ne peut pas être chargé.',
            onRetry: () => ref.invalidate(continueLearningProvider),
          ),
          data: (item) {
            if (item == null) {
              return HomeEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'Rien à reprendre pour le moment',
                message: 'Choisissez un cours pour commencer à apprendre.',
                action: AppButton(
                  label: 'Découvrir les cours',
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.small,
                  onPressed: () => context.go(AppRoutes.learning),
                ),
              );
            }

            final palette = AppColors.of(context);
            final nextRoute = item.lesson == null
                ? AppRoutes.courseDetailsPath(item.course.id)
                : AppRoutes.lessonDetailsPath(item.lesson!.id);

            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    item.lesson?.title ?? 'Reprendre ce cours',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: palette.textSecondary),
                  ),
                  if (item.module != null) ...[
                    const SizedBox(height: AppSpacing.verySmall),
                    Text(
                      item.module!.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: palette.textSecondary),
                    ),
                  ],
                  if (item.course.lessonsCount > 0) ...[
                    const SizedBox(height: AppSpacing.medium),
                    Row(
                      children: [
                        Expanded(
                          child: AppProgressBar(
                            value: item.progress,
                            semanticsLabel:
                                'Progression du cours ${item.course.title}',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Text(
                          '${item.course.completedLessons} / '
                          '${item.course.lessonsCount}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.medium),
                  AppButton(
                    label: 'Continuer',
                    icon: Icons.play_arrow_rounded,
                    size: AppButtonSize.small,
                    isExpanded: true,
                    onPressed: () => context.push(nextRoute),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
