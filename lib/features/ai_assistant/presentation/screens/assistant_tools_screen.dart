import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/assistant_tools_catalog.dart';
import '../../widgets/assistant_demo_banner.dart';

class AssistantToolsScreen extends StatelessWidget {
  const AssistantToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = assistantTools
        .map((tool) => tool.category)
        .toSet()
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Outils intelligents')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
            children: [
              const AssistantDemoBanner(),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Choisissez un point de départ. Les résultats restent '
                'des démonstrations locales.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.large),
              for (final category in categories) ...[
                Text(category, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.small),
                for (final tool in assistantTools.where(
                  (item) => item.category == category,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.small),
                    child: AppCard(
                      onTap: () =>
                          context.push(AppRoutes.assistantToolPath(tool.id)),
                      child: Row(
                        children: [
                          Icon(tool.icon),
                          const SizedBox(width: AppSpacing.medium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tool.title,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(tool.description),
                              ],
                            ),
                          ),
                          if (tool.requiredFeature != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppSpacing.small,
                              ),
                              child: Text(
                                tool.requiredFeature!.requiredPlan.name
                                    .replaceFirst('Naru ', ''),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.medium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
