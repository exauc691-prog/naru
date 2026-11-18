import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outlined, text, icon }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : assert(variant != AppButtonVariant.icon || icon != null);

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final metrics = switch (size) {
      AppButtonSize.small => const _ButtonMetrics(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
        iconSize: 18,
      ),
      AppButtonSize.medium => const _ButtonMetrics(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.large),
        iconSize: 20,
      ),
      AppButtonSize.large => const _ButtonMetrics(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.veryLarge),
        iconSize: 22,
      ),
    };
    final effectiveOnPressed = isLoading ? null : onPressed;
    final content = _buildContent(palette, metrics);
    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.buttonBorderRadius,
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.disabledSurface,
          disabledForegroundColor: palette.disabledText,
          overlayColor: palette.onPrimary.withValues(alpha: 0.12),
          elevation: 0,
          minimumSize: Size(0, metrics.height),
          padding: metrics.padding,
          shape: shape,
          textStyle: AppTextStyles.label,
        ),
        child: content,
      ),
      AppButtonVariant.secondary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.secondary,
          foregroundColor: palette.onSecondary,
          disabledBackgroundColor: palette.disabledSurface,
          disabledForegroundColor: palette.disabledText,
          overlayColor: palette.onSecondary.withValues(alpha: 0.12),
          elevation: 0,
          minimumSize: Size(0, metrics.height),
          padding: metrics.padding,
          shape: shape,
          textStyle: AppTextStyles.label,
        ),
        child: content,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          disabledForegroundColor: palette.disabledText,
          overlayColor: palette.primary.withValues(alpha: 0.08),
          side: BorderSide(color: palette.border),
          minimumSize: Size(0, metrics.height),
          padding: metrics.padding,
          shape: shape,
          textStyle: AppTextStyles.label,
        ),
        child: content,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          disabledForegroundColor: palette.disabledText,
          overlayColor: palette.primary.withValues(alpha: 0.08),
          minimumSize: Size(0, metrics.height),
          padding: metrics.padding,
          shape: shape,
          textStyle: AppTextStyles.label,
        ),
        child: content,
      ),
      AppButtonVariant.icon => IconButton.filled(
        onPressed: effectiveOnPressed,
        tooltip: label,
        style: IconButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.disabledSurface,
          disabledForegroundColor: palette.disabledText,
          overlayColor: palette.onPrimary.withValues(alpha: 0.12),
          minimumSize: Size(metrics.height, metrics.height),
          fixedSize: Size(metrics.height, metrics.height),
          padding: EdgeInsets.zero,
          shape: shape,
        ),
        icon: content,
      ),
    };

    return isExpanded && variant != AppButtonVariant.icon
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Widget _buildContent(AppColorPalette palette, _ButtonMetrics metrics) {
    if (isLoading) {
      final loadingColor = switch (variant) {
        AppButtonVariant.primary || AppButtonVariant.icon => palette.onPrimary,
        AppButtonVariant.secondary => palette.onSecondary,
        AppButtonVariant.outlined || AppButtonVariant.text => palette.primary,
      };
      return SizedBox(
        width: metrics.iconSize,
        height: metrics.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: loadingColor,
          semanticsLabel: 'Chargement',
        ),
      );
    }

    if (variant == AppButtonVariant.icon) {
      return Icon(icon, size: metrics.iconSize);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: metrics.iconSize),
          const SizedBox(width: AppSpacing.small),
        ],
        if (isExpanded)
          Flexible(
            child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          )
        else
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _ButtonMetrics {
  const _ButtonMetrics({
    required this.height,
    required this.padding,
    required this.iconSize,
  });

  final double height;
  final EdgeInsetsGeometry padding;
  final double iconSize;
}
