import 'package:flutter/material.dart';

import 'auth_text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.label,
    required this.validator,
    this.textInputAction,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final TextInputAction? textInputAction;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) => AuthTextField(
    controller: widget.controller,
    label: widget.label,
    validator: widget.validator,
    prefixIcon: Icons.lock_outline_rounded,
    obscureText: _isObscured,
    textInputAction: widget.textInputAction,
    enabled: widget.enabled,
    suffixIcon: IconButton(
      tooltip: _isObscured
          ? 'Afficher le mot de passe'
          : 'Masquer le mot de passe',
      onPressed: widget.enabled
          ? () => setState(() => _isObscured = !_isObscured)
          : null,
      icon: Icon(
        _isObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded,
      ),
    ),
  );
}
