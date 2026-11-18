import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/widgets/subscription_plan_selector.dart';

class AuthPlanScreen extends ConsumerWidget {
  const AuthPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(subscriptionPlanProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: plan.when(
              data: (selected) => ListView(
                padding: const EdgeInsets.all(AppSpacing.large),
                children: [
                  Text(
                    'Choisissez votre expérience Naru',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  SubscriptionPlanSelector(
                    selectedPlan: selected,
                    onSelected: (next) async {
                      await ref
                          .read(subscriptionPlanProvider.notifier)
                          .selectPlan(next);
                      if (context.mounted &&
                          next != SubscriptionPlan.free) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Aperçu du paiement préparé. Aucun paiement réel '
                              'n’a été effectué.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.large),
                  FilledButton(
                    onPressed: () =>
                        context.go(AppRoutes.authProfileSetup),
                    child: const Text('Continuer'),
                  ),
                ],
              ),
              error: (_, _) =>
                  const Center(child: Text('La formule ne peut pas être chargée.')),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }
}
