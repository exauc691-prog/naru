import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class LearningSearchBar extends StatefulWidget {
  const LearningSearchBar({
    super.key,
    this.initialQuery = '',
    this.onChanged,
    required this.onSubmitted,
  });

  final String initialQuery;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  State<LearningSearchBar> createState() => _LearningSearchBarState();
}

class _LearningSearchBarState extends State<LearningSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didUpdateWidget(covariant LearningSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery &&
        _controller.text != widget.initialQuery) {
      _controller.value = TextEditingValue(
        text: widget.initialQuery,
        selection: TextSelection.collapsed(offset: widget.initialQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);

    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() {});
        widget.onChanged?.call(value);
      },
      onSubmitted: (query) {
        FocusScope.of(context).unfocus();
        final trimmedQuery = query.trim();
        if (trimmedQuery.isNotEmpty) widget.onSubmitted(trimmedQuery);
      },
      decoration: InputDecoration(
        hintText: 'Rechercher un cours, un domaine ou une compétence',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  widget.onChanged?.call('');
                },
                tooltip: 'Effacer la recherche',
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: palette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.medium,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.fieldBorderRadius,
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldBorderRadius,
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldBorderRadius,
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
      ),
    );
  }
}
