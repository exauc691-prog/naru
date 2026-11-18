import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => AppButton(
    label: label,
    size: AppButtonSize.large,
    isExpanded: true,
    isLoading: isLoading,
    onPressed: isLoading ? null : onPressed,
  );
}
