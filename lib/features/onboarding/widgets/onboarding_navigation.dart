import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingNavigation extends StatelessWidget {
  const OnboardingNavigation({
    required this.isFirstPage,
    required this.isLastPage,
    required this.onPrevious,
    required this.onNext,
    required this.onSkip,
    required this.onComplete,
    super.key,
  });

  final bool isFirstPage;
  final bool isLastPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!isFirstPage && !isLastPage)
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Précédent',
                variant: AppButtonVariant.text,
                isExpanded: true,
                onPressed: onPrevious,
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: AppButton(
                label: 'Passer',
                variant: AppButtonVariant.text,
                isExpanded: true,
                onPressed: onSkip,
              ),
            ),
          ],
        )
      else
        Row(
          children: [
            if (!isFirstPage)
              AppButton(
                label: 'Précédent',
                variant: AppButtonVariant.text,
                onPressed: onPrevious,
              )
            else
              const SizedBox(width: 96, height: 48),
            const Spacer(),
            if (!isLastPage)
              AppButton(
                label: 'Passer',
                variant: AppButtonVariant.text,
                onPressed: onSkip,
              )
            else
              const SizedBox(width: 64, height: 48),
          ],
        ),
      const SizedBox(height: AppSpacing.small),
      AppButton(
        label: isLastPage ? 'Commencer maintenant' : 'Suivant',
        size: AppButtonSize.large,
        isExpanded: true,
        onPressed: isLastPage ? onComplete : onNext,
      ),
    ],
  );
}
