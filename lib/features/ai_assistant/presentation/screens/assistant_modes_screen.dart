import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../models/assistant_mode.dart';
import '../../widgets/assistant_demo_banner.dart';

class AssistantModesScreen extends StatelessWidget {
  const AssistantModesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Modes de Naru AI')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
          children: [
            Text(
              'Choisissez un mode adapté à votre objectif.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.large),
            for (final mode in AssistantMode.values) ...[
              _ModeCard(
                mode: mode,
                onTap: () {
                  if (mode == AssistantMode.documents) {
                    context.push(AppRoutes.assistantDocuments);
                  } else {
                    context.push(AppRoutes.assistantModePath(mode.name));
                  }
                },
              ),
              const SizedBox(height: AppSpacing.small),
            ],
            const SizedBox(height: AppSpacing.medium),
            const SectionTitle(title: 'Besoin d’un outil précis ?'),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.assistantTools),
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Parcourir les outils'),
            ),
            const SizedBox(height: AppSpacing.medium),
            const AssistantDemoBanner(),
          ],
        ),
      ),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onTap});

  final AssistantMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_iconForMode(mode)),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mode.label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.verySmall),
              Text(mode.description),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded),
      ],
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
