import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class AssistantDemoBanner extends StatelessWidget {
  const AssistantDemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, color: scheme.onSecondaryContainer),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              'Mode démonstration : aucune IA, aucun fournisseur ni service '
              'distant n’est connecté. Les réponses affichées sont locales.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
