import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.auto_awesome_outlined,
    this.action,
    this.maxWidth = 380,
  }) : assert(maxWidth > 0);

  final String title;
  final String? description;
  final IconData icon;
  final Widget? action;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.primaryContainer,
                  borderRadius: AppRadius.largeBorderRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Icon(
                    icon,
                    size: 32,
                    color: palette.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(color: palette.textPrimary),
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.small),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.large),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
