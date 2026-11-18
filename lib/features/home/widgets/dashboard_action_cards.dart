import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../features/library/providers/library_providers.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../library/widgets/library_resource_card.dart';

class AiAccessCard extends StatelessWidget {
  const AiAccessCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: () => context.push(AppRoutes.assistant),
    child: Row(
      children: [
        const Icon(Icons.auto_awesome_rounded),
        const SizedBox(width: AppSpacing.medium),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Naru AI'),
              Text(
                'Pose une question, résume un contenu ou crée un quiz.',
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_rounded),
      ],
    ),
  );
}

class SubscriptionStatusCard extends ConsumerWidget {
  const SubscriptionStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(subscriptionPlanProvider);
    return plan.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text(
        'Votre formule ne peut pas être chargée.',
      ),
      data: (current) => AppCard(
        onTap: () => context.push(AppRoutes.settings),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan actuel : ${current.name.replaceFirst('Naru ', '')}',
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    current.price == 0
                        ? 'Explorez les options Standard et Premium.'
                        : 'Votre formule donne accès à des ressources et outils étendus.',
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class RecommendedResourcesSection extends ConsumerWidget {
  const RecommendedResourcesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(libraryResourcesProvider);
    final featured = resources.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'À découvrir',
          trailing: TextButton(
            onPressed: () => context.go(AppRoutes.library),
            child: const Text('Voir tout'),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        for (final resource in featured)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: LibraryResourceCard(
              resource: resource,
              onTap: () => context.push(
                AppRoutes.libraryResourcePath(resource.id),
              ),
            ),
          ),
      ],
    );
  }
}
