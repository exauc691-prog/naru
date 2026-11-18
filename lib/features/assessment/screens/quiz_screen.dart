import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/enums/exercise_type.dart';
import '../../../shared/models/exercise_model.dart';
import '../../practice/providers/practice_providers.dart';
import '../models/assessment_models.dart';
import '../providers/assessment_providers.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.assessmentId});

  final String assessmentId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  String _answer = '';
  bool _validated = false;
  bool _quitPromptOpen = false;
  final _answers = <AssessmentAnswer>[];

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        leading: IconButton(
          tooltip: 'Quitter le quiz',
          onPressed: _confirmQuit,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Impossible de charger le quiz.')),
        data: (items) {
          ExerciseModel? exercise;
          try {
            exercise = items.firstWhere(
              (item) => item.id == widget.assessmentId,
            );
          } catch (_) {}
          if (exercise == null) {
            return const Center(
              child: Text('Cette activité est introuvable.'),
            );
          }
          final currentExercise = exercise;
          final isCorrect = _isCorrect(currentExercise, _answer);
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LinearProgressIndicator(value: 1),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        'Question 1 / 1',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        currentExercise.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        currentExercise.question,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      if (currentExercise.exerciseType == ExerciseType.trueFalse)
                        for (final option in const ['Vrai', 'Faux'])
                          _answerOption(option)
                      else if (currentExercise.exerciseType ==
                              ExerciseType.multipleChoice &&
                          currentExercise.options.isNotEmpty)
                        for (final option in currentExercise.options)
                          _answerOption(option)
                      else
                        TextField(
                          onChanged: (value) => setState(() => _answer = value),
                          decoration: const InputDecoration(
                            hintText: 'Saisissez votre réponse',
                          ),
                        ),
                      const SizedBox(height: AppSpacing.medium),
                      if (_validated)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.medium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCorrect ? 'Bonne réponse' : 'À revoir',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: isCorrect
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                Text(currentExercise.explanation),
                              ],
                            ),
                          ),
                        ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _answer.trim().isEmpty
                            ? null
                            : () => _validated
                                ? _finish(currentExercise)
                                : _validate(),
                        child: Text(_validated ? 'Voir le résultat' : 'Valider'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _answerOption(String option) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: OutlinedButton(
      onPressed: _validated
          ? null
          : () => setState(() {
                _answer = option;
              }),
      style: OutlinedButton.styleFrom(
        backgroundColor: _answer == option
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(option),
      ),
    ),
  );

  void _validate() => setState(() {
    _validated = true;
  });

  Future<void> _finish(ExerciseModel exercise) async {
    final correct = _isCorrect(exercise, _answer);
    _answers
      ..clear()
      ..add(
        AssessmentAnswer(
          questionId: exercise.id,
          answer: _answer,
          isCorrect: correct,
        ),
      );
    final attempt = await ref.read(assessmentAttemptsProvider.notifier).save(
          assessmentId: widget.assessmentId,
          assessmentTitle: exercise.title,
          score: correct ? 1 : 0,
          total: 1,
          answers: _answers,
        );
    if (!mounted) return;
    context.pushReplacement(
      Uri(
        path: AppRoutes.assessmentResult,
        queryParameters: {'attemptId': attempt.id},
      ).toString(),
    );
  }

  bool _isCorrect(ExerciseModel exercise, String answer) =>
      answer.trim().toLowerCase() ==
      exercise.correctAnswer.trim().toLowerCase();

  Future<void> _confirmQuit() async {
    if (_quitPromptOpen) return;
    _quitPromptOpen = true;
    final quit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le quiz ?'),
        content: const Text(
          'Ta progression actuelle sera perdue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    _quitPromptOpen = false;
    if (quit == true && mounted) context.pop();
  }
}
