import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../shared/models/learning_domain_model.dart';
import '../../learning/providers/learning_providers.dart';
import 'home_empty_state.dart';

class LearningDomainsSection extends ConsumerWidget {
  const LearningDomainsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(learningDomainsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Explorer les domaines',
          trailing: TextButton(
            onPressed: () => context.go(AppRoutes.learning),
            child: const Text('Voir tout'),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        domains.when(
          loading: () => const SizedBox(
            height: 96,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Chargement des domaines',
              ),
            ),
          ),
          error: (_, _) => AppErrorView(
            message: 'Les domaines ne peuvent pas être chargés.',
            onRetry: () => ref.invalidate(learningDomainsProvider),
          ),
          data: (items) {
            final featuredDomains = items.take(6).toList();
            if (featuredDomains.isEmpty) {
              return const HomeEmptyState(
                icon: Icons.explore_outlined,
                title: 'Aucun domaine disponible',
                message: 'Les domaines d’apprentissage apparaîtront ici.',
              );
            }

            return Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                for (final domain in featuredDomains)
                  _DomainChip(domain: domain),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({required this.domain});

  final LearningDomainModel domain;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);

    return ActionChip(
      avatar: Icon(_iconFor(domain.icon), size: 18, color: palette.primary),
      label: Text(domain.name),
      onPressed: () => context.go(
        AppRoutes.learningDomainPath(domain.id, domainName: domain.name),
      ),
      backgroundColor: palette.surface,
      side: BorderSide(color: palette.border),
      shape: const StadiumBorder(),
    );
  }

  static IconData _iconFor(String name) => switch (name) {
    'code' => Icons.code_rounded,
    'web' => Icons.web_rounded,
    'smartphone' => Icons.phone_android_rounded,
    'auto_awesome' => Icons.auto_awesome_rounded,
    'shield' => Icons.shield_outlined,
    'storage' => Icons.storage_rounded,
    'account_tree' => Icons.account_tree_outlined,
    'functions' => Icons.functions_rounded,
    'translate' => Icons.translate_rounded,
    'science' => Icons.science_outlined,
    'table_chart' => Icons.table_chart_outlined,
    'palette' => Icons.palette_outlined,
    _ => Icons.school_outlined,
  };
}
