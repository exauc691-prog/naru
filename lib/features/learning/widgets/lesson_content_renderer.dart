import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/lesson_content_block.dart';

class LessonContentRenderer extends StatelessWidget {
  const LessonContentRenderer({
    super.key,
    required this.blocks,
    required this.bookmarks,
    required this.onBookmark,
  });

  final List<LessonContentBlock> blocks;
  final Set<String> bookmarks;
  final ValueChanged<String> onBookmark;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final block in blocks) ...[
        _renderBlock(context, block),
        const SizedBox(height: AppSpacing.medium),
      ],
    ],
  );

  Widget _renderBlock(BuildContext context, LessonContentBlock block) =>
      switch (block) {
        LessonParagraphBlock(:final text) => SelectableText(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        LessonHeadingBlock(:final text, :final level) => _BookmarkableHeading(
          title: text,
          style: switch (level) {
            1 => Theme.of(context).textTheme.headlineSmall,
            2 => Theme.of(context).textTheme.titleLarge,
            3 => Theme.of(context).textTheme.titleMedium,
            _ => Theme.of(context).textTheme.titleSmall,
          },
          isBookmarked: bookmarks.contains(text),
          onBookmark: () => onBookmark(text),
        ),
        LessonListBlock(:final items, :final ordered) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < items.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text(
                        ordered ? '${index + 1}.' : '•',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        items[index],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        LessonCodeBlock(:final code, :final language) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (language != null) ...[
                Text(
                  language.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.small),
              ],
              SelectableText(
                code,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        LessonExampleBlock(:final title, :final content) => Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.small),
                LessonContentRenderer(
                  blocks: content,
                  bookmarks: bookmarks,
                  onBookmark: onBookmark,
                ),
              ],
            ),
          ),
        ),
        LessonImageBlock(:final altText, :final caption) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.large),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.image_outlined, size: 36),
              const SizedBox(height: AppSpacing.small),
              Text(altText, textAlign: TextAlign.center),
              if (caption != null) ...[
                const SizedBox(height: AppSpacing.verySmall),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.small),
              Text(
                'Illustration de démonstration',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        LessonImportantPointBlock(:final text) => Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded),
                const SizedBox(width: AppSpacing.small),
                Expanded(child: Text(text)),
                IconButton(
                  tooltip: bookmarks.contains(text)
                      ? 'Retirer le signet'
                      : 'Enregistrer un signet',
                  onPressed: () => onBookmark(text),
                  icon: Icon(
                    bookmarks.contains(text)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      };
}

class _BookmarkableHeading extends StatelessWidget {
  const _BookmarkableHeading({
    required this.title,
    required this.style,
    required this.isBookmarked,
    required this.onBookmark,
  });

  final String title;
  final TextStyle? style;
  final bool isBookmarked;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: style)),
      IconButton(
        tooltip: isBookmarked ? 'Retirer le signet' : 'Enregistrer un signet',
        onPressed: onBookmark,
        icon: Icon(
          isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_outline_rounded,
        ),
      ),
    ],
  );
}
