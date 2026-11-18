import 'package:flutter/material.dart';

import '../../../core/widgets/app_text_field.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.obscureText = false,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool obscureText;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: controller,
    label: label,
    validator: validator,
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
    suffixIcon: suffixIcon,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    enabled: enabled,
    obscureText: obscureText,
  );
}
