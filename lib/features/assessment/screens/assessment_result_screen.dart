import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/assessment_providers.dart';

class AssessmentResultScreen extends ConsumerWidget {
  const AssessmentResultScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempts = ref.watch(assessmentAttemptsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Résultat')),
      body: attempts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Impossible de charger le résultat.')),
        data: (items) {
          final attempt = items.where((item) => item.id == attemptId).firstOrNull;
          if (attempt == null) {
            return const Center(child: Text('Résultat introuvable.'));
          }
          final wrong = attempt.answers
              .where((answer) => !answer.isCorrect)
              .length;
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding:
                      const EdgeInsets.all(AppSpacing.horizontalMargin),
                  children: [
                    Text(
                      'Quiz terminé',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    AppCard(
                      child: Column(
                        children: [
                          Text(
                            '${attempt.score} / ${attempt.total}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text('${attempt.percentage} %'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Text('Résultat pédagogique',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.small),
                    AppCard(
                      child: Text(
                        wrong == 0
                            ? 'Points forts : cette notion semble bien maîtrisée.'
                            : 'À améliorer : cette notion mérite une nouvelle révision.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push(
                              AppRoutes.exerciseDetailsPath(
                                attempt.assessmentId,
                              ),
                            ),
                            child: const Text('Recommencer'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                context.go(AppRoutes.learningPaths),
                            child: const Text('Continuer mon parcours'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.assessmentHistory),
                      child: const Text('Voir l’historique'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
