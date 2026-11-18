import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/repository_providers.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/section_title.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/widgets/feature_upgrade_dialog.dart';
import '../../../shared/models/enums/exercise_type.dart';
import '../../../shared/models/enums/lesson_format.dart';
import '../../../shared/models/exercise_model.dart';
import '../../../shared/models/lesson_content_block.dart';
import '../../../shared/models/lesson_model.dart';
import '../../practice/providers/practice_providers.dart';
import '../data/lesson_local_store.dart';
import '../providers/learning_providers.dart';
import '../providers/lesson_local_providers.dart';
import '../widgets/learning_empty_state.dart';
import '../widgets/learning_formatters.dart';
import '../widgets/lesson_content_renderer.dart';

class LessonReaderScreen extends ConsumerStatefulWidget {
  const LessonReaderScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonReaderScreen> createState() => _LessonReaderScreenState();
}

class _LessonReaderScreenState extends ConsumerState<LessonReaderScreen> {
  final _scrollController = ScrollController();
  final _noteController = TextEditingController();
  final Map<String, String> _answers = {};
  final Map<String, bool> _answerResults = {};
  final Set<String> _recordedLessonIds = {};
  String? _noteLessonId;
  bool _noteDirty = false;

  @override
  void initState() {
    super.initState();
    _recordLessonOpen(widget.lessonId);
  }

  @override
  void didUpdateWidget(covariant LessonReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId) {
      _noteLessonId = null;
      _noteDirty = false;
      _answers.clear();
      _answerResults.clear();
      _recordLessonOpen(widget.lessonId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = ref.watch(lessonByIdProvider(widget.lessonId));
    return SafeArea(
      bottom: false,
      child: lesson.when(
        loading: () => const _ReaderLoading(),
        error: (_, _) => AppErrorView(
          message: 'Cette leçon ne peut pas être chargée.',
          onRetry: () => ref.invalidate(lessonByIdProvider(widget.lessonId)),
        ),
        data: (lessonModel) {
          if (lessonModel == null) {
            return const LearningEmptyState(
              title: 'Leçon introuvable',
              description: 'Cette leçon n’est pas disponible.',
            );
          }
          return _buildCourseLesson(context, lessonModel);
        },
      ),
    );
  }

  Widget _buildCourseLesson(BuildContext context, LessonModel lesson) {
    final courseData = ref.watch(coursePageDataProvider(lesson.courseId));
    return courseData.when(
      loading: () => const _ReaderLoading(),
      error: (_, _) => AppErrorView(
        message: 'Le programme de cette leçon ne peut pas être chargé.',
        onRetry: () => ref.invalidate(coursePageDataProvider(lesson.courseId)),
      ),
      data: (pageData) {
        if (pageData == null) {
          return const LearningEmptyState(
            title: 'Cours introuvable',
            description: 'Le cours associé à cette leçon est indisponible.',
          );
        }

        final localState = ref.watch(lessonLocalDataProvider(lesson.id));
        final completedIds = ref.watch(completedLessonIdsProvider);
        final exercises = ref.watch(exercisesForLessonProvider(lesson.id));
        final plan = ref.watch(subscriptionPlanProvider);

        return localState.when(
          loading: () => const _ReaderLoading(),
          error: (_, _) => AppErrorView(
            message: 'Les données locales de cette leçon sont illisibles.',
            onRetry: () => ref.invalidate(lessonLocalDataProvider(lesson.id)),
          ),
          data: (local) => completedIds.when(
            loading: () => const _ReaderLoading(),
            error: (_, _) => AppErrorView(
              message: 'La progression locale ne peut pas être chargée.',
              onRetry: () => ref.invalidate(completedLessonIdsProvider),
            ),
            data: (savedCompletedIds) => plan.when(
              loading: () => const _ReaderLoading(),
              error: (_, _) => AppErrorView(
                message: 'Le statut de la formule ne peut pas être chargé.',
                onRetry: () => ref.invalidate(subscriptionPlanProvider),
              ),
              data: (currentPlan) {
                final hasStarted =
                    pageData.course.completedLessons > 0 ||
                    savedCompletedIds.contains(lesson.id) ||
                    lesson.isCompleted;
                if (pageData.course.isPremium &&
                    !hasStarted &&
                    !SubscriptionEntitlements.canAccess(
                      currentPlan,
                      SubscriptionFeature.premiumCourses,
                    )) {
                  return _lockedLesson(context, lesson);
                }
                return exercises.when(
                  loading: () => const _ReaderLoading(),
                  error: (_, _) => AppErrorView(
                    message:
                        'Les exercices de cette leçon ne peuvent pas '
                        'être chargés.',
                    onRetry: () =>
                        ref.invalidate(exercisesForLessonProvider(lesson.id)),
                  ),
                  data: (lessonExercises) => _reader(
                    context,
                    lesson,
                    pageData,
                    local,
                    savedCompletedIds,
                    lessonExercises,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _reader(
    BuildContext context,
    LessonModel lesson,
    CoursePageData pageData,
    LessonLocalData local,
    Set<String> savedCompletedIds,
    List<ExerciseModel> exercises,
  ) {
    final history = ref.watch(lessonHistoryProvider);
    if (_noteLessonId != lesson.id) {
      _noteLessonId = lesson.id;
      _noteController.text = local.note;
      _noteDirty = false;
    }

    final allLessons = pageData.curriculum
        .expand((module) => module.lessons)
        .toList();
    final lessonIndex = allLessons.indexWhere((item) => item.id == lesson.id);
    if (lessonIndex < 0) {
      return const LearningEmptyState(
        title: 'Leçon absente du programme',
        description: 'Cette leçon n’est pas associée au programme du cours.',
      );
    }
    final currentModuleIndex = pageData.curriculum.indexWhere(
      (module) => module.lessons.any((item) => item.id == lesson.id),
    );
    final currentModule = pageData.curriculum[currentModuleIndex];
    final previousLesson = lessonIndex > 0 ? allLessons[lessonIndex - 1] : null;
    final nextLesson = lessonIndex < allLessons.length - 1
        ? allLessons[lessonIndex + 1]
        : null;
    final completedIds = {
      ...savedCompletedIds,
      for (final item in allLessons)
        if (item.isCompleted) item.id,
    };
    final completedCount = allLessons
        .where((item) => completedIds.contains(item.id))
        .length;
    final isCompleted = completedIds.contains(lesson.id);
    final remaining = allLessons
        .where((item) => !completedIds.contains(item.id))
        .fold<Duration>(
          Duration.zero,
          (total, item) => total + item.estimatedDuration,
        );
    final importantPoints = lesson.content
        .whereType<LessonImportantPointBlock>()
        .map((block) => block.text)
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.horizontalMargin,
            AppSpacing.medium,
            AppSpacing.horizontalMargin,
            AppSpacing.veryLarge,
          ),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Retour au cours',
                  onPressed: () => _goBack(context, lesson.courseId),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    pageData.course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: local.isFavorite
                      ? 'Retirer des favoris'
                      : 'Ajouter aux favoris',
                  onPressed: () =>
                      _toggleFavorite(lesson.id, !local.isFavorite),
                  icon: Icon(
                    local.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            AppProgressBar(
              value: allLessons.isEmpty
                  ? 0
                  : completedCount / allLessons.length,
              semanticsLabel: 'Progression du cours ${pageData.course.title}',
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              '${currentModule.module.title} · Leçon ${lessonIndex + 1} sur ${allLessons.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${allLessons.isEmpty ? 0 : (completedCount / allLessons.length * 100).round()} % · '
              '$completedCount/${allLessons.length} leçons terminées · '
              '$remaining restantes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            history.when(
              loading: () => const Text('Historique local en chargement…'),
              error: (error, _) => Text(
                'Historique local indisponible : $error',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              data: (items) {
                final lastViewed = items[lesson.id];
                if (lastViewed == null) {
                  return const Text(
                    'Historique de lecture enregistré localement.',
                  );
                }
                return Text(
                  'Consultée le ${_dateLabel(DateTime.parse(lastViewed).toLocal())} · '
                  'historique local',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              lesson.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              '${lesson.description} · ${durationLabel(lesson.estimatedDuration)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.medium),
            _LessonFormatNotice(format: lesson.format),
            const SizedBox(height: AppSpacing.large),
            LessonContentRenderer(
              blocks: lesson.content,
              bookmarks: local.bookmarks.toSet(),
              onBookmark: (section) => _toggleBookmark(lesson.id, section),
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Résumé et révision'),
              subtitle: const Text('Synthèse à partir du contenu de la leçon'),
              children: [
                for (final objective in lesson.objectives)
                  _BulletText(text: objective),
                if (importantPoints.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.small),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('À retenir'),
                  ),
                  for (final point in importantPoints) _BulletText(text: point),
                ],
                const Padding(
                  padding: EdgeInsets.only(
                    top: AppSpacing.small,
                    bottom: AppSpacing.medium,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Conseil : relis les exemples, puis vérifie tes acquis '
                      'avec le quiz.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const SectionTitle(title: 'Exercices et quiz'),
            const SizedBox(height: AppSpacing.small),
            if (exercises.isEmpty)
              const Text('Aucun exercice n’est associé à cette leçon.')
            else ...[
              Text(
                'Résultat : ${_answerResults.values.where((correct) => correct).length} / '
                '${_answerResults.length} vérifiées',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.small),
              for (final exercise in exercises)
                _exerciseCard(context, exercise),
            ],
            const SizedBox(height: AppSpacing.section),
            const SectionTitle(title: 'Mes notes'),
            const SizedBox(height: AppSpacing.small),
            TextField(
              controller: _noteController,
              minLines: 3,
              maxLines: 8,
              onChanged: (_) => setState(() => _noteDirty = true),
              decoration: const InputDecoration(
                hintText: 'Note personnelle pour cette leçon…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  label: 'Enregistrer la note',
                  icon: Icons.save_outlined,
                  isExpanded: true,
                  onPressed: _noteDirty ? () => _saveNote(lesson.id) : null,
                ),
                if (local.note.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      label: 'Supprimer',
                      variant: AppButtonVariant.text,
                      onPressed: () => _deleteNote(lesson.id),
                    ),
                  ),
              ],
            ),
            if (local.bookmarks.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.section),
              const SectionTitle(title: 'Signets enregistrés'),
              for (final section in local.bookmarks)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bookmark_outline_rounded),
                  title: Text(section),
                  trailing: IconButton(
                    tooltip: 'Retirer le signet',
                    onPressed: () => _toggleBookmark(lesson.id, section),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.section),
            if (isCompleted)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leçon terminée',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Bravo, ta progression locale a été actualisée.'
                        '${_answerResults.isEmpty ? '' : ' Quiz : ${_answerResults.values.where((value) => value).length}/${_answerResults.length}.'}',
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Wrap(
                        spacing: AppSpacing.small,
                        children: [
                          TextButton(
                            onPressed: () => _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                            child: const Text('Revoir la leçon'),
                          ),
                          if (nextLesson != null)
                            TextButton(
                              onPressed: () => _openLesson(nextLesson.id),
                              child: const Text('Leçon suivante'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              AppButton(
                label: 'Terminer la leçon',
                isExpanded: true,
                onPressed: () => _completeLesson(lesson.id),
              ),
            const SizedBox(height: AppSpacing.medium),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Programme du cours'),
              subtitle: Text(
                '${pageData.curriculum.length} modules · ${allLessons.length} leçons',
              ),
              children: [
                for (
                  var moduleIndex = 0;
                  moduleIndex < pageData.curriculum.length;
                  moduleIndex++
                )
                  _moduleTile(
                    context,
                    pageData.curriculum[moduleIndex],
                    moduleIndex,
                    completedIds,
                    lesson.id,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const SectionTitle(title: 'Historique récent'),
            const SizedBox(height: AppSpacing.small),
            _historySection(context, history, allLessons),
            const SizedBox(height: AppSpacing.large),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Précédente',
                    variant: AppButtonVariant.outlined,
                    onPressed: previousLesson == null
                        ? null
                        : () => _openLesson(previousLesson.id),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: AppButton(
                    label: nextLesson == null ? 'Fin du cours' : 'Suivante',
                    onPressed: nextLesson == null
                        ? null
                        : () => _openLesson(nextLesson.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleTile(
    BuildContext context,
    LearningModuleContent module,
    int moduleIndex,
    Set<String> completedIds,
    String currentLessonId,
  ) {
    final completeCount = module.lessons
        .where((lesson) => completedIds.contains(lesson.id))
        .length;
    final progress = module.lessons.isEmpty
        ? 0
        : (completeCount / module.lessons.length * 100).round();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text('Module ${moduleIndex + 1} · ${module.module.title}'),
      subtitle: Text(
        '$progress % · ${module.lessons.length} leçons · '
        '$completeCount terminées',
      ),
      children: [
        for (final lesson in module.lessons)
          ListTile(
            contentPadding: const EdgeInsets.only(left: AppSpacing.medium),
            selected: lesson.id == currentLessonId,
            leading: Icon(
              completedIds.contains(lesson.id)
                  ? Icons.check_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
            ),
            title: Text(lesson.title),
            subtitle: Text(durationLabel(lesson.estimatedDuration)),
            onTap: () => _openLesson(lesson.id),
          ),
      ],
    );
  }

  Widget _historySection(
    BuildContext context,
    AsyncValue<Map<String, String>> history,
    List<LessonModel> allLessons,
  ) => history.when(
    loading: () => const LinearProgressIndicator(),
    error: (error, _) => Text('Historique local indisponible : $error'),
    data: (items) {
      final lessonsById = {for (final lesson in allLessons) lesson.id: lesson};
      final recent =
          items.entries
              .where((entry) => lessonsById.containsKey(entry.key))
              .toList()
            ..sort(
              (first, second) =>
                  DateTime.parse(second.value)
                      .compareTo(DateTime.parse(first.value)),
            );
      if (recent.isEmpty) {
        return const Text('Aucune leçon consultée récemment.');
      }
      return Column(
        children: [
          for (final entry in recent.take(3))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded),
              title: Text(lessonsById[entry.key]!.title),
              subtitle: Text(_dateLabel(DateTime.parse(entry.value).toLocal())),
              onTap: () => _openLesson(entry.key),
            ),
        ],
      );
    },
  );

  Widget _exerciseCard(BuildContext context, ExerciseModel exercise) {
    final selectedAnswer = _answers[exercise.id] ?? '';
    final result = _answerResults[exercise.id];
    final options = exercise.exerciseType == ExerciseType.trueFalse
        ? const ['Vrai', 'Faux']
        : exercise.options;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.small),
            Text(exercise.question),
            if (options.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  for (final option in options)
                    ChoiceChip(
                      label: Text(option),
                      selected: selectedAnswer == option,
                      onSelected: (_) => setState(() {
                        _answers[exercise.id] = option;
                        _answerResults.remove(exercise.id);
                      }),
                    ),
                ],
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.small),
              TextField(
                key: ValueKey(exercise.id),
                onChanged: (value) => setState(() {
                  _answers[exercise.id] = value;
                  _answerResults.remove(exercise.id);
                }),
                decoration: const InputDecoration(
                  hintText: 'Ta réponse',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.small),
            AppButton(
              label: 'Vérifier',
              variant: AppButtonVariant.outlined,
              onPressed: selectedAnswer.trim().isEmpty
                  ? null
                  : () => _checkAnswer(exercise),
            ),
            if (result != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                result ? 'Bonne réponse' : 'À revoir',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: result
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
              ),
              Text(exercise.explanation),
              if (!result) Text('Réponse attendue : ${exercise.correctAnswer}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _lockedLesson(
    BuildContext context,
    LessonModel lesson,
  ) => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.large),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: LearningEmptyState(
          title: 'Cours Premium',
          description:
              'Cette leçon appartient à un cours Premium. Tu peux consulter '
              'la présentation du cours ou découvrir les formules Naru.',
          icon: Icons.lock_outline_rounded,
          action: AppButton(
            label: 'Découvrir Premium',
            isExpanded: true,
            onPressed: () async {
              await requireSubscriptionFeature(
                context,
                ref,
                SubscriptionFeature.premiumCourses,
              );
            },
          ),
        ),
      ),
    ),
  );

  Future<void> _recordLessonOpen(String lessonId) async {
    if (!_recordedLessonIds.add(lessonId)) return;
    try {
      await ref.read(lessonLocalStoreProvider).recordOpened(lessonId);
      if (mounted) ref.invalidate(lessonHistoryProvider);
    } catch (error) {
      _recordedLessonIds.remove(lessonId);
      _showMessage('Impossible d’enregistrer l’historique local : $error');
    }
  }

  Future<void> _toggleFavorite(String lessonId, bool isFavorite) async {
    try {
      await ref
          .read(lessonLocalStoreProvider)
          .setFavorite(lessonId, isFavorite);
      if (mounted) ref.invalidate(lessonLocalDataProvider(lessonId));
    } catch (error) {
      _showMessage('Impossible de modifier les favoris : $error');
    }
  }

  Future<void> _toggleBookmark(String lessonId, String section) async {
    try {
      await ref
          .read(lessonLocalStoreProvider)
          .toggleBookmark(lessonId, section);
      if (mounted) ref.invalidate(lessonLocalDataProvider(lessonId));
    } catch (error) {
      _showMessage('Impossible d’enregistrer le signet : $error');
    }
  }

  Future<void> _saveNote(String lessonId) async {
    try {
      await ref
          .read(lessonLocalStoreProvider)
          .saveNote(lessonId, _noteController.text);
      if (!mounted) return;
      _noteDirty = false;
      ref.invalidate(lessonLocalDataProvider(lessonId));
      _showMessage('Note enregistrée sur cet appareil.');
    } catch (error) {
      _showMessage('Impossible d’enregistrer la note : $error');
    }
  }

  Future<void> _deleteNote(String lessonId) async {
    try {
      await ref.read(lessonLocalStoreProvider).saveNote(lessonId, '');
      if (!mounted) return;
      _noteController.clear();
      _noteDirty = false;
      ref.invalidate(lessonLocalDataProvider(lessonId));
      _showMessage('Note supprimée.');
    } catch (error) {
      _showMessage('Impossible de supprimer la note : $error');
    }
  }

  Future<void> _completeLesson(String lessonId) async {
    try {
      await ref.read(lessonLocalStoreProvider).setCompleted(lessonId);
      if (!mounted) return;
      ref.invalidate(lessonLocalDataProvider(lessonId));
      ref.invalidate(completedLessonIdsProvider);
    } catch (error) {
      _showMessage('Impossible d’enregistrer la progression : $error');
    }
  }

  Future<void> _checkAnswer(ExerciseModel exercise) async {
    try {
      final result = await ref
          .read(exerciseRepositoryProvider)
          .checkAnswer(exercise.id, _answers[exercise.id] ?? '');
      if (result == null) {
        throw StateError('The exercise ${exercise.id} is no longer available.');
      }
      if (!mounted) return;
      setState(() => _answerResults[exercise.id] = result);
    } catch (error) {
      _showMessage('Impossible de vérifier la réponse : $error');
    }
  }

  void _openLesson(String lessonId) =>
      context.go(AppRoutes.lessonDetailsPath(lessonId));

  void _goBack(BuildContext context, String courseId) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.courseDetailsPath(courseId));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LessonFormatNotice extends StatelessWidget {
  const _LessonFormatNotice({required this.format});

  final LessonFormat format;

  @override
  Widget build(BuildContext context) {
    final details = switch (format) {
      LessonFormat.text => null,
      LessonFormat.video => (
        Icons.play_circle_outline_rounded,
        'Leçon vidéo',
        'Aucune vidéo réelle n’est connectée. Le contenu écrit ci-dessous '
            'sert de démonstration.',
      ),
      LessonFormat.illustrated => (
        Icons.image_outlined,
        'Leçon illustrée',
        'Les illustrations sont présentées comme des aperçus fictifs.',
      ),
      LessonFormat.audio => (
        Icons.headphones_rounded,
        'Leçon audio',
        'Aucun fichier audio réel n’est connecté. Le contenu écrit reste '
            'disponible.',
      ),
      LessonFormat.document => (
        Icons.description_outlined,
        'Document pédagogique',
        'Aucun document distant n’est joint. Cette fiche de démonstration '
            'reprend les notions de la leçon.',
      ),
    };
    if (details == null) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(details.$1),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.$2,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.verySmall),
                  Text(details.$3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});

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

class _ReaderLoading extends StatelessWidget {
  const _ReaderLoading();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(semanticsLabel: 'Chargement de la leçon'),
  );
}

String _dateLabel(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}
