import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../subscription/models/subscription_plan.dart';
import '../../../subscription/providers/subscription_providers.dart';
import '../../data/assistant_quota_config.dart';
import '../../models/assistant_mode.dart';
import '../../models/assistant_usage.dart';
import '../../providers/assistant_providers.dart';
import '../../widgets/assistant_composer.dart';
import '../../widgets/assistant_demo_banner.dart';
import '../../widgets/assistant_feedback.dart';

class AssistantHomeScreen extends ConsumerStatefulWidget {
  const AssistantHomeScreen({super.key});

  @override
  ConsumerState<AssistantHomeScreen> createState() =>
      _AssistantHomeScreenState();
}

class _AssistantHomeScreenState extends ConsumerState<AssistantHomeScreen> {
  final _composerKey = GlobalKey<AssistantComposerState>();

  static const _suggestions = [
    'Explique-moi les bases de Python.',
    'Aide-moi à comprendre les fractions.',
    'Comment préparer un programme de révision ?',
    'Aide-moi à structurer un projet.',
  ];

  Future<bool> _send(String prompt) async {
    try {
      final id = await ref
          .read(assistantControllerProvider.notifier)
          .startConversation(mode: AssistantMode.learn, content: prompt);
      if (mounted) context.push(AppRoutes.assistantConversationPath(id));
      return true;
    } on AssistantQuotaExceeded catch (error) {
      if (mounted) await showAssistantQuotaDialog(context, ref, error);
      return false;
    } catch (error) {
      if (mounted) showAssistantError(context, error);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assistant = ref.watch(assistantControllerProvider);
    final plan = ref.watch(subscriptionPlanProvider);
    final palette = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.horizontalMargin,
                      AppSpacing.medium,
                      AppSpacing.horizontalMargin,
                      AppSpacing.large,
                    ),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: palette.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: palette.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.small),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Naru AI',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text('Votre assistant intelligent'),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Historique',
                            onPressed: () =>
                                context.push(AppRoutes.assistantHistory),
                            icon: const Icon(Icons.history_rounded),
                          ),
                          IconButton(
                            tooltip: 'Paramètres de l’assistant',
                            onPressed: () =>
                                context.push(AppRoutes.assistantSettings),
                            icon: const Icon(Icons.tune_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        'Apprenez, créez et explorez de nouvelles possibilités.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      const AssistantDemoBanner(),
                      const SizedBox(height: AppSpacing.medium),
                      assistant.when(
                        data: (state) => plan.when(
                          data: (currentPlan) => _UsageIndicator(
                            used: state.usage.count(
                              AssistantQuotaKind.messages,
                            ),
                            limit: ref
                                .read(assistantQuotaConfigProvider)
                                .limitFor(
                                  currentPlan,
                                  AssistantQuotaKind.messages,
                                ),
                            plan: currentPlan,
                          ),
                          error: (error, stack) => const SizedBox.shrink(),
                          loading: () => const LinearProgressIndicator(),
                        ),
                        error: (error, stack) => const Text(
                          'Les données locales de l’assistant sont indisponibles.',
                        ),
                        loading: () => const LinearProgressIndicator(),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        'Bonjour ! Que souhaitez-vous apprendre ou accomplir aujourd’hui ?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      const SectionTitle(
                        title: 'Quelques idées pour commencer',
                      ),
                      const SizedBox(height: AppSpacing.small),
                      for (final suggestion in _suggestions)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.small,
                          ),
                          child: AppCard(
                            onTap: () =>
                                _composerKey.currentState?.setDraft(suggestion),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.medium,
                              vertical: AppSpacing.small,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_outward_rounded),
                                const SizedBox(width: AppSpacing.small),
                                Expanded(child: Text(suggestion)),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.medium),
                      SectionTitle(
                        title: 'Que souhaitez-vous faire ?',
                        trailing: TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.assistantModes),
                          child: const Text('Tous les modes'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Wrap(
                        spacing: AppSpacing.small,
                        runSpacing: AppSpacing.small,
                        children: [
                          for (final mode in const [
                            AssistantMode.learn,
                            AssistantMode.homework,
                            AssistantMode.writing,
                            AssistantMode.programming,
                            AssistantMode.translation,
                            AssistantMode.organization,
                          ])
                            ActionChip(
                              avatar: Icon(_iconForMode(mode), size: 18),
                              label: Text(mode.label),
                              onPressed: () => context.push(
                                AppRoutes.assistantModePath(mode.name),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.large),
                      Wrap(
                        spacing: AppSpacing.small,
                        runSpacing: AppSpacing.small,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.push(AppRoutes.assistantDocuments),
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Documents'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.push(AppRoutes.assistantTools),
                            icon: const Icon(Icons.grid_view_rounded),
                            label: const Text('Outils'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.push(AppRoutes.assistantFavorites),
                            icon: const Icon(Icons.bookmarks_outlined),
                            label: const Text('Favoris'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.push(AppRoutes.assistantVoice),
                            icon: const Icon(Icons.mic_none_rounded),
                            label: const Text('Voix (aperçu)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AssistantComposer(
                  key: _composerKey,
                  onSend: _send,
                  onAttachment: () =>
                      context.push(AppRoutes.assistantDocuments),
                  onVoice: () => context.push(AppRoutes.assistantVoice),
                  isEnabled: assistant.hasValue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForMode(AssistantMode mode) => switch (mode) {
    AssistantMode.learn => Icons.school_outlined,
    AssistantMode.homework => Icons.edit_note_rounded,
    AssistantMode.writing => Icons.draw_outlined,
    AssistantMode.documents => Icons.description_outlined,
    AssistantMode.programming => Icons.code_rounded,
    AssistantMode.translation => Icons.translate_rounded,
    AssistantMode.organization => Icons.account_tree_outlined,
  };
}

class _UsageIndicator extends StatelessWidget {
  const _UsageIndicator({
    required this.used,
    required this.limit,
    required this.plan,
  });

  final int used;
  final int limit;
  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$used / $limit messages de démonstration utilisés aujourd’hui · '
      '${plan.name}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
