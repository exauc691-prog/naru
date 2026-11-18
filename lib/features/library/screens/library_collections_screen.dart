import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../models/library_collection.dart';
import '../models/library_resource.dart';
import '../providers/library_providers.dart';
import '../widgets/library_resource_card.dart';

class LibraryCollectionsScreen extends ConsumerWidget {
  const LibraryCollectionsScreen({super.key, this.collectionId});

  final String? collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = ref.watch(libraryLocalStateProvider);
    final resources = ref.watch(libraryResourcesProvider);
    return SafeArea(
      bottom: false,
      child: local.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'Les collections ne peuvent pas être chargées.',
          onRetry: () => ref.invalidate(libraryLocalStateProvider),
        ),
        data: (state) {
          if (collectionId == null) {
            return _collectionList(context, ref, state.collections);
          }
          LibraryCollection? collection;
          for (final item in state.collections) {
            if (item.id == collectionId) {
              collection = item;
              break;
            }
          }
          if (collection == null) {
            return const AppEmptyState(
              title: 'Collection introuvable',
              description: 'Elle a peut-être été supprimée.',
              icon: Icons.collections_bookmark_outlined,
            );
          }
          final selected = resources
              .where(
                (resource) => collection!.resourceIds.contains(resource.id),
              )
              .toList();
          return _collectionDetail(context, ref, collection, selected);
        },
      ),
    );
  }

  Widget _collectionList(
    BuildContext context,
    WidgetRef ref,
    List<LibraryCollection> collections,
  ) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.horizontalMargin,
          AppSpacing.medium,
          AppSpacing.horizontalMargin,
          AppSpacing.veryLarge,
        ),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Retour à la bibliothèque',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  'Collections personnelles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Créer une collection',
                onPressed: () => _createCollection(context, ref),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          const AppCard(
            child: Text(
              'Créez des listes adaptées à vos cours, projets et lectures. '
              'Elles sont conservées sur cet appareil.',
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          if (collections.isEmpty)
            AppEmptyState(
              title: 'Aucune collection pour le moment',
              description:
                  'Créez une collection, puis ajoutez-y les ressources qui '
                  'vous intéressent.',
              icon: Icons.collections_bookmark_outlined,
              action: FilledButton.icon(
                onPressed: () => _createCollection(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Créer une collection'),
              ),
            )
          else
            for (final collection in collections)
              AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.small),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.collections_bookmark_outlined),
                  title: Text(collection.name),
                  subtitle: Text(
                    '${collection.resourceIds.length} ressource${collection.resourceIds.length == 1 ? '' : 's'}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(
                    AppRoutes.libraryCollectionPath(collection.id),
                  ),
                ),
              ),
        ],
      ),
    ),
  );

  Widget _collectionDetail(
    BuildContext context,
    WidgetRef ref,
    LibraryCollection collection,
    List<LibraryResource> resources,
  ) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.horizontalMargin,
          AppSpacing.medium,
          AppSpacing.horizontalMargin,
          AppSpacing.veryLarge,
        ),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Retour aux collections',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  collection.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Options de la collection',
                onSelected: (value) {
                  if (value == 'rename') {
                    _renameCollection(context, ref, collection);
                  } else {
                    _deleteCollection(context, ref, collection);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'rename', child: Text('Renommer')),
                  PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          FilledButton.icon(
            onPressed: () => context.push(
              AppRoutes.libraryCatalogPath(collectionId: collection.id),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter des ressources'),
          ),
          const SizedBox(height: AppSpacing.medium),
          if (resources.isEmpty)
            const AppEmptyState(
              title: 'Cette collection est vide',
              description:
                  'Ajoutez des livres ou documents depuis le catalogue.',
              icon: Icons.menu_book_outlined,
            )
          else
            for (final resource in resources)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: LibraryResourceCard(
                  resource: resource,
                  onTap: () =>
                      context.push(AppRoutes.libraryResourcePath(resource.id)),
                  trailing: IconButton(
                    tooltip: 'Retirer de la collection',
                    onPressed: () =>
                        _removeResource(context, ref, collection.id, resource),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ),
              ),
        ],
      ),
    ),
  );

  Future<void> _createCollection(BuildContext context, WidgetRef ref) async {
    final name = await _askForName(context, title: 'Nouvelle collection');
    if (name == null || !context.mounted) return;
    try {
      final collection = await ref
          .read(libraryLocalStoreProvider)
          .createCollection(name);
      if (!context.mounted) return;
      ref.invalidate(libraryLocalStateProvider);
      context.push(AppRoutes.libraryCollectionPath(collection.id));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Impossible de créer la collection : $error');
    }
  }

  Future<void> _renameCollection(
    BuildContext context,
    WidgetRef ref,
    LibraryCollection collection,
  ) async {
    final name = await _askForName(
      context,
      title: 'Renommer la collection',
      initialValue: collection.name,
    );
    if (name == null || !context.mounted) return;
    try {
      await ref
          .read(libraryLocalStoreProvider)
          .renameCollection(collection.id, name);
      ref.invalidate(libraryLocalStateProvider);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Impossible de renommer la collection : $error');
    }
  }

  Future<void> _deleteCollection(
    BuildContext context,
    WidgetRef ref,
    LibraryCollection collection,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la collection ?'),
        content: Text('La collection « ${collection.name} » sera supprimée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(libraryLocalStoreProvider).deleteCollection(collection.id);
      if (!context.mounted) return;
      ref.invalidate(libraryLocalStateProvider);
      context.pop();
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Impossible de supprimer la collection : $error');
    }
  }

  Future<void> _removeResource(
    BuildContext context,
    WidgetRef ref,
    String collectionId,
    LibraryResource resource,
  ) async {
    try {
      await ref
          .read(libraryLocalStoreProvider)
          .toggleCollectionResource(collectionId, resource.id);
      ref.invalidate(libraryLocalStateProvider);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Impossible de retirer la ressource : $error');
    }
  }

  Future<String?> _askForName(
    BuildContext context, {
    required String title,
    String initialValue = '',
  }) => showDialog<String>(
    context: context,
    builder: (context) =>
        _CollectionNameDialog(title: title, initialValue: initialValue),
  );

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CollectionNameDialog extends StatefulWidget {
  const _CollectionNameDialog({
    required this.title,
    required this.initialValue,
  });

  final String title;
  final String initialValue;

  @override
  State<_CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<_CollectionNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLength: 48,
      decoration: const InputDecoration(
        labelText: 'Nom',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (value) => Navigator.pop(context, value),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Enregistrer'),
      ),
    ],
  );
}
