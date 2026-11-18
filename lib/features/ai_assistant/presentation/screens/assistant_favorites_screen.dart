import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../models/assistant_saved_item.dart';
import '../../providers/assistant_providers.dart';
import '../../widgets/assistant_demo_banner.dart';
import '../../widgets/assistant_feedback.dart';

class AssistantFavoritesScreen extends ConsumerStatefulWidget {
  const AssistantFavoritesScreen({super.key});

  @override
  ConsumerState<AssistantFavoritesScreen> createState() =>
      _AssistantFavoritesScreenState();
}

class _AssistantFavoritesScreenState
    extends ConsumerState<AssistantFavoritesScreen> {
  final _searchController = TextEditingController();
  String _category = 'Toutes';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: state.when(
        data: (assistant) {
          final query = _searchController.text.trim().toLowerCase();
          final categories = {
            'Toutes',
            for (final item in assistant.savedItems) item.category,
          }.toList();
          final items = assistant.savedItems.where((item) {
            final matchesQuery = query.isEmpty ||
                item.title.toLowerCase().contains(query) ||
                item.content.toLowerCase().contains(query);
            final matchesCategory =
                _category == 'Toutes' || item.category == _category;
            return matchesQuery && matchesCategory;
          }).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
                children: [
                  const AssistantDemoBanner(),
                  const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher dans les favoris',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in categories)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.small,
                            ),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: _category == category,
                              onSelected: (_) =>
                                  setState(() => _category = category),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (items.isEmpty)
                    const AppEmptyState(
                      icon: Icons.bookmark_border_rounded,
                      title: 'Aucune réponse enregistrée',
                      description:
                          'Ajoutez une réponse depuis une conversation.',
                    )
                  else
                    for (final item in items)
                      _SavedItemCard(
                        item: item,
                        onCopy: () async {
                          await Clipboard.setData(
                            ClipboardData(text: item.content),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Réponse copiée.'),
                              ),
                            );
                          }
                        },
                        onDelete: () async {
                          try {
                            await ref
                                .read(assistantControllerProvider.notifier)
                                .deleteSavedItem(item.id);
                          } catch (error) {
                            if (context.mounted) {
                              showAssistantError(context, error);
                            }
                          }
                        },
                      ),
                ],
              ),
            ),
          );
        },
        error: (error, stack) =>
            const Center(child: Text('Impossible de charger les favoris.')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SavedItemCard extends StatelessWidget {
  const _SavedItemCard({
    required this.item,
    required this.onCopy,
    required this.onDelete,
  });

  final AssistantSavedItem item;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.verySmall),
          Text(item.category,
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: AppSpacing.small),
          Text(item.content),
          const SizedBox(height: AppSpacing.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Copier',
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                tooltip: 'Supprimer',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
