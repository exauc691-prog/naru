import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../shared/models/enums/course_format.dart';
import '../../../shared/models/enums/difficulty_level.dart';
import '../data/course_catalog_filters.dart';
import 'learning_formatters.dart';

class CourseFilterSheet extends StatefulWidget {
  const CourseFilterSheet({super.key, required this.initialFilters});

  final CourseCatalogFilters initialFilters;

  @override
  State<CourseFilterSheet> createState() => _CourseFilterSheetState();
}

class _CourseFilterSheetState extends State<CourseFilterSheet> {
  late DifficultyLevel? _level = widget.initialFilters.level;
  late CourseDurationRange? _duration = widget.initialFilters.duration;
  late bool? _isPremium = widget.initialFilters.isPremium;
  late CourseFormat? _format = widget.initialFilters.format;

  CourseCatalogFilters get _filters => CourseCatalogFilters(
    level: _level,
    duration: _duration,
    isPremium: _isPremium,
    format: _format,
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.horizontalMargin,
        top: AppSpacing.large,
        right: AppSpacing.horizontalMargin,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.medium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filtrer les cours',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Fermer les filtres',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterGroup(
                    context,
                    title: 'Niveau',
                    children: [
                      _choice(
                        label: 'Tous',
                        selected: _level == null,
                        onSelected: () => setState(() => _level = null),
                      ),
                      for (final level in DifficultyLevel.values)
                        _choice(
                          label: difficultyLabel(level),
                          selected: _level == level,
                          onSelected: () => setState(() => _level = level),
                        ),
                    ],
                  ),
                  _filterGroup(
                    context,
                    title: 'Durée',
                    children: [
                      _choice(
                        label: 'Toutes',
                        selected: _duration == null,
                        onSelected: () => setState(() => _duration = null),
                      ),
                      for (final range in CourseDurationRange.values)
                        _choice(
                          label: range.label,
                          selected: _duration == range,
                          onSelected: () => setState(() => _duration = range),
                        ),
                    ],
                  ),
                  _filterGroup(
                    context,
                    title: 'Type de cours',
                    children: [
                      _choice(
                        label: 'Tous',
                        selected: _isPremium == null,
                        onSelected: () => setState(() => _isPremium = null),
                      ),
                      _choice(
                        label: 'Gratuit',
                        selected: _isPremium == false,
                        onSelected: () => setState(() => _isPremium = false),
                      ),
                      _choice(
                        label: 'Premium',
                        selected: _isPremium == true,
                        onSelected: () => setState(() => _isPremium = true),
                      ),
                    ],
                  ),
                  _filterGroup(
                    context,
                    title: 'Format',
                    children: [
                      _choice(
                        label: 'Tous',
                        selected: _format == null,
                        onSelected: () => setState(() => _format = null),
                      ),
                      for (final format in CourseFormat.values)
                        _choice(
                          label: format.label,
                          selected: _format == format,
                          onSelected: () => setState(() => _format = format),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _filters.isEmpty
                      ? null
                      : () => setState(() {
                          _level = null;
                          _duration = null;
                          _isPremium = null;
                          _format = null;
                        }),
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'Appliquer',
                  isExpanded: true,
                  onPressed: () => Navigator.pop(context, _filters),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _filterGroup(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.medium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: children,
        ),
      ],
    ),
  );

  Widget _choice({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onSelected(),
  );
}
