import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/subscription_plan.dart';
import '../providers/subscription_providers.dart';

class SubscriptionPlanSelector extends ConsumerWidget {
  const SubscriptionPlanSelector({
    super.key,
    required this.selectedPlan,
    required this.onSelected,
  });

  final SubscriptionPlan selectedPlan;
  final ValueChanged<SubscriptionPlan> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final pricing = ref.watch(subscriptionPricingConfigProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez votre formule',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.verySmall),
        Text(
          'Aucun paiement ni moyen de paiement n’est demandé à cette étape.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.medium),
        for (final plan in SubscriptionPlan.values) ...[
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: selectedPlan == plan || plan == SubscriptionPlan.premium
                    ? colors.primary
                    : colors.outlineVariant,
                width: selectedPlan == plan ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (plan == SubscriptionPlan.premium)
                        Text(
                          'Formule complète',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.verySmall),
                  Text(
                    pricing.priceFor(plan),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(plan.description),
                  const SizedBox(height: AppSpacing.small),
                  for (final feature in plan.features)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.verySmall,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: AppSpacing.small),
                          Expanded(child: Text(feature)),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: selectedPlan == plan
                          ? null
                          : () => onSelected(plan),
                      child: Text(
                        selectedPlan == plan
                            ? 'Formule sélectionnée'
                            : 'Choisir ${plan.name.replaceFirst('Naru ', '')}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (plan != SubscriptionPlan.values.last)
            const SizedBox(height: AppSpacing.small),
        ],
      ],
    );
  }
}
