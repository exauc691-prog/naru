import 'package:flutter/material.dart';

import '../../../core/widgets/app_empty_state.dart';

class LearningEmptyState extends StatelessWidget {
  const LearningEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.search_off_rounded,
    this.action,
  });

  final String title;
  final String? description;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    title: title,
    description: description,
    icon: icon,
    action: action,
    maxWidth: 360,
  );
}
