import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.medium),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppRadius.cardBorderRadius,
    this.showBorder = true,
    this.elevation = 0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final bool showBorder;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: showBorder
          ? BorderSide(color: borderColor ?? palette.border)
          : BorderSide.none,
    );

    return Padding(
      padding: margin,
      child: Material(
        color: backgroundColor ?? palette.surface,
        elevation: elevation,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
