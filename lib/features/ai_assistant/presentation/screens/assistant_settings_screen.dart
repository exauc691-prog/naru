import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../subscription/providers/subscription_providers.dart';
import '../../models/assistant_usage.dart';
import '../../providers/assistant_providers.dart';
import '../../widgets/assistant_demo_banner.dart';
import '../../widgets/assistant_feedback.dart';

class AssistantSettingsScreen extends ConsumerWidget {
  const AssistantSettingsScreen({super.key});

  Future<void> _clearData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer les données de Naru AI ?'),
        content: const Text(
          'Cette action supprime localement les conversations, les exemples '
          'de documents et l’historique des aperçus vocaux.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(assistantControllerProvider.notifier).clearPersonalData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les données locales ont été effacées.'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) showAssistantError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(subscriptionPlanProvider);
    final state = ref.watch(assistantControllerProvider);
    final quotaConfig = ref.watch(assistantQuotaConfigProvider);
    final modelCatalog = ref.watch(aiModelCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres de Naru AI')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
            children: [
              const AssistantDemoBanner(),
              const SizedBox(height: AppSpacing.large),
              const SectionTitle(title: 'Confidentialité et données'),
              const SizedBox(height: AppSpacing.small),
              const AppCard(
                child: Text(
                  'Les conversations, documents-exemples et aperçus vocaux '
                  'ainsi que les réponses enregistrées sont stockés localement '
                  'sur cet appareil. Aucun texte '
                  'n’est transmis à un fournisseur d’IA dans cette version. '
                  'Les futures analyses nécessiteront une connexion au '
                  'backend sécurisé.',
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              FilledButton.tonalIcon(
                onPressed: () => _clearData(context, ref),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Effacer les données de Naru AI'),
              ),
              const SizedBox(height: AppSpacing.large),
              const SectionTitle(
                title: 'Limites de démonstration',
                subtitle:
                    'Valeurs configurables, sans promesse de quota illimité.',
              ),
              const SizedBox(height: AppSpacing.small),
              plan.when(
                data: (currentPlan) => AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentPlan.name} · réinitialisation quotidienne',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      for (final kind in AssistantQuotaKind.values)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '${_quotaName(kind)} : '
                            '${quotaConfig.limitFor(currentPlan, kind)} '
                            '${_quotaUnit(kind)}',
                          ),
                        ),
                    ],
                  ),
                ),
                error: (error, stack) =>
                    const Text('Impossible de charger la formule actuelle.'),
                loading: () => const LinearProgressIndicator(),
              ),
              const SizedBox(height: AppSpacing.large),
              const SectionTitle(title: 'Modèles et fournisseurs'),
              const SizedBox(height: AppSpacing.small),
              AppCard(
                child: Text(
                  modelCatalog.models.isEmpty
                      ? 'Le routage selon la formule, la tâche, la complexité '
                            'et le coût est préparé. Aucun modèle ou fournisseur '
                            'n’est enregistré ni connecté.'
                      : 'Un catalogue de modèles est configuré.',
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              const SectionTitle(title: 'État de l’historique'),
              const SizedBox(height: AppSpacing.small),
              state.when(
                data: (assistant) => AppCard(
                  child: Text(
                    '${assistant.conversations.length} conversation(s), '
                    '${assistant.documents.length} document(s) exemple(s), '
                    '${assistant.voiceHistory.length} aperçu(s) vocal(aux), '
                    '${assistant.savedItems.length} réponse(s) enregistrée(s).',
                  ),
                ),
                error: (error, stack) =>
                    const Text('Les données locales ne sont pas disponibles.'),
                loading: () => const LinearProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _quotaName(AssistantQuotaKind kind) => switch (kind) {
  AssistantQuotaKind.messages => 'Conversations',
  AssistantQuotaKind.documentAnalyses => 'Analyses de documents',
  AssistantQuotaKind.generations => 'Générations',
  AssistantQuotaKind.voiceMinutes => 'Voix à venir',
};

String _quotaUnit(AssistantQuotaKind kind) =>
    kind == AssistantQuotaKind.voiceMinutes ? 'min/jour' : 'actions/jour';
