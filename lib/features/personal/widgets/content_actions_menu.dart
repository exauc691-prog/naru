import 'package:flutter/material.dart';

class ContentActionsMenu extends StatelessWidget {
  const ContentActionsMenu({
    super.key,
    required this.onFavorite,
    this.onBookmark,
    this.onAddToCollection,
    this.onCreateNote,
  });

  final VoidCallback onFavorite;
  final VoidCallback? onBookmark;
  final VoidCallback? onAddToCollection;
  final VoidCallback? onCreateNote;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Plus d’actions',
    onSelected: (value) => switch (value) {
      'favorite' => onFavorite(),
      'bookmark' => onBookmark?.call(),
      'collection' => onAddToCollection?.call(),
      'note' => onCreateNote?.call(),
      _ => null,
    },
    itemBuilder: (context) => [
      const PopupMenuItem(value: 'favorite', child: Text('Ajouter ou retirer des favoris')),
      if (onBookmark != null)
        const PopupMenuItem(value: 'bookmark', child: Text('Ajouter un signet')),
      if (onAddToCollection != null)
        const PopupMenuItem(value: 'collection', child: Text('Ajouter à une collection')),
      if (onCreateNote != null)
        const PopupMenuItem(value: 'note', child: Text('Créer une note')),
    ],
  );
}
