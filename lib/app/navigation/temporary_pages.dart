import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../router/app_routes.dart';

class TemporaryPage extends StatelessWidget {
  const TemporaryPage({
    required this.title,
    required this.description,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(description, style: Theme.of(context).textTheme.bodyLarge),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.large),
                  ...actions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: action,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context) => TemporaryPage(
    title: 'Page introuvable',
    description: 'Aucune page ne correspond à « $path ».',
    actions: [
      AppButton(
        label: 'Retour à l’accueil',
        isExpanded: true,
        onPressed: () => context.go(AppRoutes.welcome),
      ),
    ],
  );
}
