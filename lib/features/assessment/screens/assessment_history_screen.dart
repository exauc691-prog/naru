import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../providers/assessment_providers.dart';

class AssessmentHistoryScreen extends ConsumerWidget {
  const AssessmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempts = ref.watch(assessmentAttemptsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des évaluations')),
      body: attempts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Impossible de charger l’historique.')),
        data: (items) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: items.isEmpty
                ? const AppEmptyState(
                    icon: Icons.history_rounded,
                    title: 'Aucun résultat',
                    description:
                        'Terminez une activité pour enregistrer une tentative.',
                  )
                : ListView(
                    padding:
                        const EdgeInsets.all(AppSpacing.horizontalMargin),
                    children: [
                      for (final attempt in items)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.small,
                          ),
                          child: AppCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(attempt.assessmentTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall),
                                      Text(
                                        '${attempt.completedAt.day}/'
                                        '${attempt.completedAt.month}/'
                                        '${attempt.completedAt.year} · '
                                        '${attempt.attemptNumber} tentative(s)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${attempt.percentage} %',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
