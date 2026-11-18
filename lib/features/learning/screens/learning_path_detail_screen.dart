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
import '../../../shared/models/lesson_model.dart';
import '../providers/learning_providers.dart';
import '../widgets/course_level_badge.dart';
import '../widgets/learning_curriculum_list.dart';
import '../widgets/learning_empty_state.dart';
import '../widgets/learning_formatters.dart';
import '../widgets/learning_header.dart';

class LearningPathDetailScreen extends ConsumerWidget {
  const LearningPathDetailScreen({super.key, required this.pathId});

  final String pathId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageData = ref.watch(learningPathPageDataProvider(pathId));

    return SafeArea(
      bottom: false,
      child: pageData.when(
        loading: () => const _PathLoading(),
        error: (_, _) => AppErrorView(
          message:
              'Les informations de ce parcours ne peuvent pas être chargées.',
          onRetry: () => ref.invalidate(learningPathPageDataProvider(pathId)),
        ),
        data: (data) {
          if (data == null) return const _PathNotFound();

          final path = data.path;
          final objectives = <String>{
            for (final module in data.curriculum)
              for (final lesson in module.lessons) ...lesson.objectives,
          }.toList();
          final skills = <String>{
            for (final course in data.courses) ...course.tags,
          }.toList();
          final nextLesson = _nextLesson(data.curriculum);
          final firstLesson = _firstLesson(data.curriculum);
          final targetLesson = nextLesson ?? firstLesson;
          final buttonLabel = nextLesson == null
              ? path.progressPercentage > 0 || path.isCompleted
                    ? 'Revoir le parcours'
                    : 'Commencer le parcours'
              : path.progressPercentage > 0
              ? 'Continuer le parcours'
              : 'Commencer le parcours';
          final palette = AppColors.of(context);
          final progressPercent = path.progressPercentage
              .clamp(0.0, 100.0)
              .round();
          final hasProgress = progressPercent > 0 || path.isCompleted;

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
                    title: 'Détail du parcours',
                    description: path.title,
                    onBack: () => _goBack(context),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CourseLevelBadge(level: path.level),
                      Text(
                        data.domain?.name ?? path.domainId,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: palette.textSecondary),
                      ),
                      Text(
                        durationLabel(path.estimatedDuration),
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: palette.textSecondary),
                      ),
                      if (path.moduleIds.isNotEmpty)
                        Text(
                          '${path.moduleIds.length} modules',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: palette.textSecondary),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    path.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (hasProgress) ...[
                    const SizedBox(height: AppSpacing.large),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Progression du parcours',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Text('$progressPercent %'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    AppProgressBar(
                      value: progressPercent / 100,
                      semanticsLabel: 'Progression du parcours ${path.title}',
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
                      _PathObjective(text: objective),
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle(title: 'Compétences abordées'),
                  const SizedBox(height: AppSpacing.small),
                  if (skills.isEmpty)
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
                        for (final skill in skills) Chip(label: Text(skill)),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle(title: 'Modules et leçons'),
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
                        : () => context.push(
                            AppRoutes.lessonDetailsPath(targetLesson.id),
                          ),
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
      context.go(AppRoutes.learningPaths);
    }
  }
}

class _PathObjective extends StatelessWidget {
  const _PathObjective({required this.text});

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

class _PathLoading extends StatelessWidget {
  const _PathLoading();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(semanticsLabel: 'Chargement du parcours'),
  );
}

class _PathNotFound extends StatelessWidget {
  const _PathNotFound();

  @override
  Widget build(BuildContext context) => const Center(
    child: LearningEmptyState(
      title: 'Détail du parcours',
      description: 'Ce parcours est introuvable.',
      icon: Icons.route_outlined,
    ),
  );
}
