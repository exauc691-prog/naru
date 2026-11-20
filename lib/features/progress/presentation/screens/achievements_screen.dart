import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../providers/progress_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(unlockedAchievementsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Badges et récompenses')),
      body: achievements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'Les récompenses ne peuvent pas être chargées.',
          onRetry: () => ref.invalidate(unlockedAchievementsProvider),
        ),
        data: (items) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: items.isEmpty
                ? const AppEmptyState(
                    icon: Icons.emoji_events_outlined,
                    title: 'Aucun badge obtenu',
                    description:
                        'Continuez à apprendre pour débloquer vos premiers badges.',
                  )
                : ListView(
                    padding: const EdgeInsets.all(
                      AppSpacing.horizontalMargin,
                    ),
                    children: [
                      for (final achievement in items)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.small,
                          ),
                          child: AppCard(
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  child: Icon(Icons.emoji_events_outlined),
                                ),
                                const SizedBox(width: AppSpacing.medium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        achievement.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      Text(achievement.description),
                                    ],
                                  ),
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
