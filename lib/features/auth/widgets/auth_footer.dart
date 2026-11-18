import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class AuthFooter extends StatelessWidget {
  const AuthFooter({
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
    super.key,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.verySmall),
        child: Text(
          prompt,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
      TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
          minimumSize: const Size(0, 44),
        ),
        child: Text(actionLabel),
      ),
    ],
  );
}
