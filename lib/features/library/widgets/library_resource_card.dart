import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/library_resource.dart';

class LibraryResourceCover extends StatelessWidget {
  const LibraryResourceCover({
    super.key,
    required this.resource,
    this.width = 96,
    this.height = 132,
  });

  final LibraryResource resource;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = _coverColor(resource.categoryId);
    final icon = switch (resource.type) {
      LibraryResourceType.book => Icons.menu_book_rounded,
      LibraryResourceType.pdf => Icons.picture_as_pdf_outlined,
      LibraryResourceType.guide => Icons.auto_stories_outlined,
      LibraryResourceType.revisionSheet => Icons.fact_check_outlined,
      LibraryResourceType.courseMaterial => Icons.school_outlined,
    };

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.72)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 23),
          Text(
            resource.coverGlyph,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryResourceCard extends StatelessWidget {
  const LibraryResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
    this.isGrid = false,
    this.isFavorite = false,
    this.trailing,
  });

  final LibraryResource resource;
  final VoidCallback onTap;
  final bool isGrid;
  final bool isFavorite;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final availabilityColor = switch (resource.availability) {
      LibraryAvailability.free => colors.primary,
      LibraryAvailability.standard => colors.tertiary,
      LibraryAvailability.premium => colors.error,
      LibraryAvailability.individualPurchase => colors.secondary,
    };

    return AppCard(
      onTap: onTap,
      padding: isGrid
          ? const EdgeInsets.all(AppSpacing.small)
          : const EdgeInsets.all(AppSpacing.medium),
      child: isGrid
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: LibraryResourceCover(
                    resource: resource,
                    width: 112,
                    height: 148,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                _resourceInformation(context, availabilityColor, trailing),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LibraryResourceCover(
                  resource: resource,
                  width: 76,
                  height: 104,
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: _resourceInformation(
                    context,
                    availabilityColor,
                    trailing,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _resourceInformation(
    BuildContext context,
    Color availabilityColor,
    Widget? trailing,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              resource.title,
              maxLines: isGrid ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (isFavorite)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.verySmall),
              child: Icon(Icons.favorite_rounded, size: 18),
            ),
          ?trailing,
        ],
      ),
      const SizedBox(height: AppSpacing.verySmall),
      Text(
        resource.author,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: AppSpacing.small),
      Wrap(
        spacing: AppSpacing.verySmall,
        runSpacing: AppSpacing.verySmall,
        children: [
          _Badge(label: resource.availability.label, color: availabilityColor),
          _Badge(
            label: resource.type.label,
            color: Theme.of(context).colorScheme.outline,
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.verySmall),
      Text(
        '${resource.rating}/5 · ${resource.pages ?? '—'} pages',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    ],
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.small,
      vertical: AppSpacing.verySmall,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: color, fontWeight: FontWeight.w600),
    ),
  );
}

Color _coverColor(String categoryId) => switch (categoryId) {
  'programmation' => const Color(0xFF345995),
  'informatique' => const Color(0xFF4D6B59),
  'intelligence-artificielle' => const Color(0xFF6D5AA6),
  'sciences' => const Color(0xFF357A73),
  'mathematiques' => const Color(0xFF386FA4),
  'litterature' => const Color(0xFF9A5A66),
  'histoire' => const Color(0xFF8A6945),
  'economie' => const Color(0xFF527A54),
  'langues' => const Color(0xFF9A703A),
  'entrepreneuriat' => const Color(0xFF4D6792),
  'developpement-personnel' => const Color(0xFF7C5F76),
  _ => const Color(0xFF5C7180),
};
