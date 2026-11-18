import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.maxLines = 1,
  }) : assert(maxLines > 0 && (!obscureText || maxLines == 1));

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);

    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
      maxLines: maxLines,
      cursorColor: palette.primary,
      style: AppTextStyles.body.copyWith(color: palette.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? palette.surface : palette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.medium,
        ),
        labelStyle: AppTextStyles.body.copyWith(color: palette.textSecondary),
        hintStyle: AppTextStyles.body.copyWith(color: palette.textSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: palette.error),
        enabledBorder: _border(palette.border),
        disabledBorder: _border(palette.border),
        focusedBorder: _border(palette.primary, width: 1.5),
        errorBorder: _border(palette.error),
        focusedErrorBorder: _border(palette.error, width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadius.fieldBorderRadius,
        borderSide: BorderSide(color: color, width: width),
      );
}
