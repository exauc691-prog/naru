import 'package:flutter/material.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
  });

  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
    onPressed: onToggle,
    icon: Icon(
      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
    ),
  );
}
