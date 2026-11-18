import 'package:flutter/material.dart';

@immutable
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.disabledSurface,
    required this.disabledText,
    required this.success,
    required this.warning,
    required this.error,
    required this.onError,
    required this.info,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color accent;
  final Color onAccent;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color disabledSurface;
  final Color disabledText;
  final Color success;
  final Color warning;
  final Color error;
  final Color onError;
  final Color info;
}

abstract final class AppColors {
  static const light = AppColorPalette(
    primary: Color(0xFF4F46E5),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE9E8FF),
    onPrimaryContainer: Color(0xFF28216F),
    secondary: Color(0xFF0F766E),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD9F3EE),
    onSecondaryContainer: Color(0xFF003C36),
    accent: Color(0xFFF4B942),
    onAccent: Color(0xFF3D2B00),
    background: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF0F2F8),
    border: Color(0xFFE2E5EF),
    textPrimary: Color(0xFF182033),
    textSecondary: Color(0xFF626C80),
    disabledSurface: Color(0xFFE8EAF0),
    disabledText: Color(0xFF9299A8),
    success: Color(0xFF16834A),
    warning: Color(0xFFA95F00),
    error: Color(0xFFC2414B),
    onError: Color(0xFFFFFFFF),
    info: Color(0xFF0878A8),
  );

  static const dark = AppColorPalette(
    primary: Color(0xFFAAA4FF),
    onPrimary: Color(0xFF221B60),
    primaryContainer: Color(0xFF393174),
    onPrimaryContainer: Color(0xFFE9E8FF),
    secondary: Color(0xFF68CFC1),
    onSecondary: Color(0xFF003C36),
    secondaryContainer: Color(0xFF164942),
    onSecondaryContainer: Color(0xFFD0FFF5),
    accent: Color(0xFFFFD06A),
    onAccent: Color(0xFF3D2B00),
    background: Color(0xFF111522),
    surface: Color(0xFF191F2E),
    surfaceMuted: Color(0xFF232A3B),
    border: Color(0xFF343C50),
    textPrimary: Color(0xFFF3F4FA),
    textSecondary: Color(0xFFB1B8C8),
    disabledSurface: Color(0xFF303648),
    disabledText: Color(0xFF858DA1),
    success: Color(0xFF72D6A0),
    warning: Color(0xFFFFCB72),
    error: Color(0xFFFF8A91),
    onError: Color(0xFF3B0910),
    info: Color(0xFF75C6F0),
  );

  static AppColorPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
