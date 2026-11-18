import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../data/assistant_quota_config.dart';

Future<void> showAssistantQuotaDialog(
  BuildContext context,
  WidgetRef ref,
  AssistantQuotaExceeded error,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Limite quotidienne atteinte'),
      content: Text(
        '${error.message}\n\n'
        'Les limites sont configurables et se réinitialisent demain. '
        'Votre historique est conservé ; vous pouvez continuer avec les '
        'fonctionnalités gratuites.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Continuer gratuitement'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            context.push(AppRoutes.settings);
          },
          child: const Text('Voir les formules'),
        ),
      ],
    ),
  );
}

void showAssistantError(BuildContext context, Object error) {
  debugPrint('Naru assistant action failed: $error');
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(
          'Cette action n’a pas abouti. Vos données précédentes sont conservées.',
        ),
      ),
    );
}
