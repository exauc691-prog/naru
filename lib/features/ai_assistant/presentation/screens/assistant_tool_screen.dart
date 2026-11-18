import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../subscription/widgets/feature_upgrade_dialog.dart';
import '../../data/assistant_quota_config.dart';
import '../../data/assistant_tools_catalog.dart';
import '../../models/assistant_usage.dart';
import '../../providers/assistant_providers.dart';
import '../../widgets/assistant_demo_banner.dart';
import '../../widgets/assistant_feedback.dart';

class AssistantToolScreen extends ConsumerStatefulWidget {
  const AssistantToolScreen({required this.toolId, super.key});

  final String toolId;

  @override
  ConsumerState<AssistantToolScreen> createState() =>
      _AssistantToolScreenState();
}

class _AssistantToolScreenState extends ConsumerState<AssistantToolScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run(AssistantToolDefinition tool) async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez un sujet ou un texte pour continuer.'),
        ),
      );
      return;
    }

    try {
      final requiredFeature = tool.requiredFeature;
      if (requiredFeature != null &&
          !await requireSubscriptionFeature(context, ref, requiredFeature)) {
        return;
      }
      final id = await ref
          .read(assistantControllerProvider.notifier)
          .startConversation(
            mode: tool.mode,
            content: 'Outil : ${tool.title}\n\n${tool.promptHint}\n$content',
            additionalQuotaKind: AssistantQuotaKind.generations,
          );
      if (mounted) context.push(AppRoutes.assistantConversationPath(id));
    } on AssistantQuotaExceeded catch (error) {
      if (mounted) await showAssistantQuotaDialog(context, ref, error);
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tool = _toolById(widget.toolId);
    if (tool == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Outil introuvable')),
        body: const Center(child: Text('Cet outil n’est pas disponible.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(tool.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
            children: [
              const AssistantDemoBanner(),
              const SizedBox(height: AppSpacing.medium),
              AppCard(
                child: Row(
                  children: [
                    Icon(tool.icon, size: 28),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tool.category,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(tool.description),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (tool.requiredFeature != null) ...[
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Fonctionnalité prévue avec '
                  '${tool.requiredFeature!.requiredPlan.name}.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.large),
              TextField(
                controller: _controller,
                minLines: 4,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: tool.promptHint,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              FilledButton.icon(
                onPressed: () => _run(tool),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Créer une réponse de démonstration'),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Le texte saisi sera enregistré dans votre historique local '
                'de démonstration. Aucun service externe ne le reçoit.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AssistantToolDefinition? _toolById(String id) {
  for (final tool in assistantTools) {
    if (tool.id == id) return tool;
  }
  return null;
}
