import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/section_title.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/widgets/feature_upgrade_dialog.dart';
import '../../../shared/models/lesson_model.dart';
import '../providers/learning_providers.dart';
import '../widgets/course_level_badge.dart';
import '../widgets/learning_curriculum_list.dart';
import '../widgets/learning_empty_state.dart';
import '../widgets/learning_formatters.dart';
import '../widgets/learning_header.dart';
import '../widgets/learning_domain_icon.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageData = ref.watch(coursePageDataProvider(courseId));

    return SafeArea(
      bottom: false,
      child: pageData.when(
        loading: () => const _CourseLoading(),
        error: (_, _) => AppErrorView(
          message: 'Les informations de ce cours ne peuvent pas être chargées.',
          onRetry: () => ref.invalidate(coursePageDataProvider(courseId)),
        ),
        data: (data) {
          if (data == null) {
            return const _CourseNotFound();
          }

          final course = data.course;
          final lessons = data.curriculum.expand((part) => part.lessons);
          final objectives = <String>{
            for (final lesson in lessons) ...lesson.objectives,
          }.toList();
          final nextLesson = _nextLesson(data.curriculum);
          final firstLesson = _firstLesson(data.curriculum);
          final targetLesson = nextLesson ?? firstLesson;
          final buttonLabel = nextLesson != null
              ? course.completedLessons > 0
                    ? 'Continuer le cours'
                    : 'Commencer le cours'
              : course.completedLessons > 0
              ? 'Revoir le cours'
              : 'Commencer le cours';
          final palette = AppColors.of(context);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.horizontalMargin,
                  AppSpacing.large,
                  AppSpacing.horizontalMargin,
                  AppSpacing.veryLarge,
                ),
                children: [
                  LearningHeader(
                    title: 'Détail du cours',
                    description: course.title,
                    onBack: () => _goBack(context),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Container(
                    height: 128,
                    decoration: BoxDecoration(
                      color: palette.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      learningDomainIcon(course.domainId),
                      size: 48,
                      color: palette.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CourseLevelBadge(level: course.difficulty),
                      Text(
                        data.domain?.name ?? course.domainId,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: palette.textSecondary),
                      ),
                      Text(
                        durationLabel(course.estimatedDuration),
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: palette.textSecondary),
                      ),
                      Text(
                        course.isPremium ? 'Premium' : 'Gratuit',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: palette.textSecondary),
                      ),
                      Text(
                        course.format.label,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: palette.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Avec ${course.instructorName} · ${course.lessonsCount} leçons · '
                    '${course.rating.toStringAsFixed(1)} / 5 · '
                    '${learnerCountLabel(course.enrolledStudents)}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: palette.textSecondary),
                  ),
                  if (course.completedLessons > 0 &&
                      course.lessonsCount > 0) ...[
                    const SizedBox(height: AppSpacing.large),
                    _CourseProgress(
                      completedLessons: course.completedLessons,
                      lessonsCount: course.lessonsCount,
                      title: course.title,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle(title: 'Objectifs pédagogiques'),
                  const SizedBox(height: AppSpacing.small),
                  if (objectives.isEmpty)
                    const LearningEmptyState(
                      title: 'Objectifs en préparation',
                      description:
                          'Les objectifs seront précisés dans les leçons.',
                      icon: Icons.flag_outlined,
                    )
                  else
                    for (final objective in objectives)
                      _ObjectiveItem(text: objective),
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle(title: 'Prérequis'),
                  const SizedBox(height: AppSpacing.small),
                  if (course.prerequisites.isEmpty)
                    Text(
                      'Aucun prérequis renseigné.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: palette.textSecondary),
                    )
                  else
                    for (final prerequisite in course.prerequisites)
                      _ObjectiveItem(text: prerequisite),
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle(title: 'Compétences abordées'),
                  const SizedBox(height: AppSpacing.small),
                  if (course.tags.isEmpty)
                    Text(
                      'Aucune compétence n’est renseignée pour le moment.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: palette.textSecondary),
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.small,
                      runSpacing: AppSpacing.small,
                      children: [
                        for (final tag in course.tags) Chip(label: Text(tag)),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle(title: 'Programme du cours'),
                  const SizedBox(height: AppSpacing.small),
                  LearningCurriculumList(
                    curriculum: data.curriculum,
                    onLessonTap: (lesson) =>
                        context.push(AppRoutes.lessonDetailsPath(lesson.id)),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppButton(
                    label: targetLesson == null
                        ? 'Contenu bientôt disponible'
                        : buttonLabel,
                    icon: targetLesson == null
                        ? null
                        : Icons.play_arrow_rounded,
                    isExpanded: true,
                    onPressed: targetLesson == null
                        ? null
                        : () async {
                            if (course.isPremium &&
                                course.completedLessons == 0 &&
                                !await requireSubscriptionFeature(
                                  context,
                                  ref,
                                  SubscriptionFeature.premiumCourses,
                                )) {
                              return;
                            }
                            if (!context.mounted) return;
                            context.push(
                              AppRoutes.lessonDetailsPath(targetLesson.id),
                            );
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static LessonModel? _nextLesson(List<LearningModuleContent> curriculum) {
    for (final module in curriculum) {
      for (final lesson in module.lessons) {
        if (!lesson.isCompleted) return lesson;
      }
    }
    return null;
  }

  static LessonModel? _firstLesson(List<LearningModuleContent> curriculum) {
    for (final module in curriculum) {
      if (module.lessons.isNotEmpty) return module.lessons.first;
    }
    return null;
  }

  static void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.learning);
    }
  }
}

class _CourseProgress extends StatelessWidget {
  const _CourseProgress({
    required this.completedLessons,
    required this.lessonsCount,
    required this.title,
  });

  final int completedLessons;
  final int lessonsCount;
  final String title;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Ta progression',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text('$completedLessons / $lessonsCount leçons'),
        ],
      ),
      const SizedBox(height: AppSpacing.small),
      AppProgressBar(
        value: completedLessons / lessonsCount,
        semanticsLabel: 'Progression du cours $title',
      ),
    ],
  );
}

class _ObjectiveItem extends StatelessWidget {
  const _ObjectiveItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_rounded, size: 18),
        const SizedBox(width: AppSpacing.small),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _CourseLoading extends StatelessWidget {
  const _CourseLoading();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(semanticsLabel: 'Chargement du cours'),
  );
}

class _CourseNotFound extends StatelessWidget {
  const _CourseNotFound();

  @override
  Widget build(BuildContext context) => const Center(
    child: LearningEmptyState(
      title: 'Détail du cours',
      description: 'Ce cours est introuvable.',
      icon: Icons.menu_book_outlined,
    ),
  );
}
