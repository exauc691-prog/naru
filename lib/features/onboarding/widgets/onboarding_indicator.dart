import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    required this.count,
    required this.currentIndex,
    super.key,
  }) : assert(count > 0),
       assert(currentIndex >= 0 && currentIndex < count);

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Page ${currentIndex + 1} sur $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isSelected = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: isSelected ? 26 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.verySmall,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }
}
