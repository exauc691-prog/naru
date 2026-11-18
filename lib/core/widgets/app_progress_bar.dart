import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    this.value,
    this.height = 8,
    this.color,
    this.trackColor,
    this.semanticsLabel = 'Progression',
  }) : assert(height > 0);

  final double? value;
  final double height;
  final Color? color;
  final Color? trackColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final normalizedValue = value?.clamp(0.0, 1.0).toDouble();
    final semanticValue = normalizedValue == null
        ? 'Indéterminée'
        : '${(normalizedValue * 100).round()} %';

    return Semantics(
      label: semanticsLabel,
      value: semanticValue,
      child: ExcludeSemantics(
        child: LinearProgressIndicator(
          value: normalizedValue,
          minHeight: height,
          color: color ?? palette.primary,
          backgroundColor: trackColor ?? palette.surfaceMuted,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}
