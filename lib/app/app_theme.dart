import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static final ThemeData lightTheme = _createTheme(
    AppColors.light,
    Brightness.light,
  );

  static final ThemeData darkTheme = _createTheme(
    AppColors.dark,
    Brightness.dark,
  );

  static ThemeData _createTheme(
    AppColorPalette palette,
    Brightness brightness,
  ) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: brightness,
        ).copyWith(
          primary: palette.primary,
          onPrimary: palette.onPrimary,
          primaryContainer: palette.primaryContainer,
          onPrimaryContainer: palette.onPrimaryContainer,
          secondary: palette.secondary,
          onSecondary: palette.onSecondary,
          secondaryContainer: palette.secondaryContainer,
          onSecondaryContainer: palette.onSecondaryContainer,
          tertiary: palette.accent,
          onTertiary: palette.onAccent,
          error: palette.error,
          onError: palette.onError,
          surface: palette.surface,
          onSurface: palette.textPrimary,
          surfaceContainerHighest: palette.surfaceMuted,
          onSurfaceVariant: palette.textSecondary,
          outline: palette.border,
          outlineVariant: palette.border,
        );
    final textTheme = TextTheme(
      displayLarge: AppTextStyles.display.copyWith(color: palette.textPrimary),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: palette.textPrimary,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: palette.textPrimary,
      ),
      headlineLarge: AppTextStyles.headline.copyWith(
        color: palette.textPrimary,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: palette.textPrimary,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: palette.textPrimary,
      ),
      titleLarge: AppTextStyles.title.copyWith(color: palette.textPrimary),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: palette.textPrimary,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: palette.textPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: palette.textPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: palette.textPrimary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: palette.textSecondary),
      labelLarge: AppTextStyles.label.copyWith(color: palette.textPrimary),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: palette.textSecondary,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: palette.textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: palette.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: palette.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: palette.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorderRadius,
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.medium,
        ),
        labelStyle: AppTextStyles.body.copyWith(color: palette.textSecondary),
        hintStyle: AppTextStyles.body.copyWith(color: palette.textSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: palette.error),
        enabledBorder: _inputBorder(palette.border),
        disabledBorder: _inputBorder(palette.border),
        focusedBorder: _inputBorder(palette.primary, width: 1.5),
        errorBorder: _inputBorder(palette.error),
        focusedErrorBorder: _inputBorder(palette.error, width: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.disabledSurface,
          disabledForegroundColor: palette.disabledText,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorderRadius,
          ),
          elevation: 0,
          textStyle: AppTextStyles.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          disabledForegroundColor: palette.disabledText,
          side: BorderSide(color: palette.border),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorderRadius,
          ),
          textStyle: AppTextStyles.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          disabledForegroundColor: palette.disabledText,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorderRadius,
          ),
          textStyle: AppTextStyles.label,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        elevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.modalBorderRadius,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        surfaceTintColor: palette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.modal),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadius.fieldBorderRadius,
        borderSide: BorderSide(color: color, width: width),
      );
}
