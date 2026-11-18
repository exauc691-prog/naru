import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../models/subscription_plan.dart';
import '../providers/subscription_providers.dart';
import '../widgets/subscription_plan_selector.dart';

class SubscriptionSettingsScreen extends ConsumerWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPlan = ref.watch(subscriptionPlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Formule Naru')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: selectedPlan.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Chargement de la formule',
                ),
              ),
              error: (_, _) => AppErrorView(
                message: 'La formule actuelle ne peut pas être chargée.',
                onRetry: () => ref.invalidate(subscriptionPlanProvider),
              ),
              data: (plan) => SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre formule actuelle : ${plan.name}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.verySmall),
                    Text(
                      'Sélection locale de démonstration. Aucun paiement '
                      'n’est effectué et aucune période de facturation '
                      'n’est définie.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    SubscriptionPlanSelector(
                      selectedPlan: plan,
                      onSelected: (nextPlan) =>
                          _selectPlan(context, ref, nextPlan),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectPlan(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
  ) async {
    try {
      await ref.read(subscriptionPlanProvider.notifier).selectPlan(plan);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formule mise à jour : ${plan.name}.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de modifier la formule : $error')),
      );
    }
  }
}
