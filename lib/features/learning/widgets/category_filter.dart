import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/learning_domain_model.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    required this.domains,
    required this.selectedDomainId,
    required this.onSelected,
  });

  final List<LearningDomainModel> domains;
  final String? selectedDomainId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.small),
          child: ChoiceChip(
            label: const Text('Tous'),
            selected: selectedDomainId == null,
            onSelected: (_) => onSelected(null),
          ),
        ),
        for (final domain in domains)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.small),
            child: ChoiceChip(
              label: Text(domain.name),
              selected: selectedDomainId == domain.id,
              onSelected: (_) => onSelected(domain.id),
            ),
          ),
      ],
    ),
  );
}
