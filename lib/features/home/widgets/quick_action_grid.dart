import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_title.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = <(IconData, String, String)>[
      (Icons.school_outlined, 'Cours', AppRoutes.learning),
      (Icons.local_library_outlined, 'Bibliothèque', AppRoutes.library),
      (Icons.auto_awesome_rounded, 'Naru AI', AppRoutes.assistant),
      (Icons.favorite_border_rounded, 'Favoris', AppRoutes.assistantFavorites),
      (Icons.download_outlined, 'Téléchargements', '/app/home/library/downloads'),
      (Icons.flag_outlined, 'Objectifs', AppRoutes.progress),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Accès rapides'),
        const SizedBox(height: AppSpacing.small),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.small,
            crossAxisSpacing: AppSpacing.small,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return AppCard(
              onTap: () => context.push(action.$3),
              padding: const EdgeInsets.all(AppSpacing.small),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action.$1),
                  const SizedBox(height: AppSpacing.verySmall),
                  Text(
                    action.$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
