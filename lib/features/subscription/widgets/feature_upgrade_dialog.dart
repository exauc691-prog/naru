import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../models/subscription_plan.dart';
import '../providers/subscription_providers.dart';

Future<bool> requireSubscriptionFeature(
  BuildContext context,
  WidgetRef ref,
  SubscriptionFeature feature,
) async {
  final plan = await ref.read(subscriptionPlanProvider.future);
  if (!context.mounted) return false;
  if (SubscriptionEntitlements.canAccess(plan, feature)) return true;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      scrollable: true,
      title: Text(feature.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cette ressource est réservée à la formule '
            '${feature.requiredPlan.name}. ${feature.description}',
          ),
          const SizedBox(height: 16),
          Text(
            'Disponible avec ${feature.requiredPlan.name} '
            '(${ref.read(subscriptionPricingConfigProvider).priceFor(feature.requiredPlan)}).',
          ),
          const SizedBox(height: 12),
          Text(
            'Avantages inclus :',
            style: Theme.of(dialogContext).textTheme.titleSmall,
          ),
          for (final benefit in feature.requiredPlan.features.take(3))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('• $benefit'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Fermer'),
        ),
        AppButton(
          label:
              'Découvrir ${feature.requiredPlan.name.replaceFirst('Naru ', '')}',
          isExpanded: true,
          onPressed: () {
            Navigator.pop(dialogContext);
            context.push(AppRoutes.settings);
          },
        ),
      ],
    ),
  );
  return false;
}
