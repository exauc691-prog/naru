import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../data/library_local_store.dart';
import '../models/library_collection.dart';
import '../models/library_resource.dart';
import '../providers/library_providers.dart';
import '../widgets/library_resource_card.dart';

enum _PersonalLibraryFilter {
  all('Tous'),
  books('Livres'),
  documents('Documents'),
  favorites('Favoris'),
  recent('Récemment consultés'),
  downloads('Téléchargés'),
  collections('Collections');

  const _PersonalLibraryFilter(this.label);

  final String label;
}

class MyLibraryScreen extends ConsumerStatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  ConsumerState<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends ConsumerState<MyLibraryScreen> {
  final _queryController = TextEditingController();
  _PersonalLibraryFilter _filter = _PersonalLibraryFilter.all;
  bool _sortAlphabetically = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = ref.watch(libraryLocalStateProvider);
    final resources = ref.watch(libraryResourcesProvider);
    return SafeArea(
      bottom: false,
      child: local.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'Votre bibliothèque personnelle ne peut pas être chargée.',
          onRetry: () => ref.invalidate(libraryLocalStateProvider),
        ),
        data: (state) {
          final filtered = _filterResources(resources, state);
          return Center(
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
                          'Ma bibliothèque',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Téléchargements',
                        onPressed: () =>
                            context.push(AppRoutes.libraryDownloads),
                        icon: const Icon(Icons.download_outlined),
                      ),
                      IconButton(
                        tooltip: 'Collections',
                        onPressed: () =>
                            context.push(AppRoutes.libraryCollections),
                        icon: const Icon(Icons.collections_bookmark_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: _queryController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Rechercher dans ma bibliothèque',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _queryController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Effacer',
                              onPressed: () {
                                _queryController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final filter in _PersonalLibraryFilter.values) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.small,
                            ),
                            child: ChoiceChip(
                              label: Text(filter.label),
                              selected: _filter == filter,
                              onSelected: (_) =>
                                  setState(() => _filter = filter),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (_filter == _PersonalLibraryFilter.collections)
                    _collectionsContent(state.collections)
                  else ...[
                    SectionTitle(
                      title: '${filtered.length} ressources',
                      trailing: TextButton.icon(
                        onPressed: () => setState(
                          () => _sortAlphabetically = !_sortAlphabetically,
                        ),
                        icon: const Icon(Icons.sort_by_alpha_rounded),
                        label: Text(
                          _sortAlphabetically ? 'Plus récentes' : 'A à Z',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    if (filtered.isEmpty)
                      AppEmptyState(
                        title: _filter == _PersonalLibraryFilter.all
                            ? 'Votre bibliothèque est vide'
                            : 'Aucune ressource ici',
                        description:
                            'Ajoutez des livres et documents pour les retrouver '
                            'facilement sur cet appareil.',
                        icon: Icons.library_books_outlined,
                        action: FilledButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.libraryCatalogPath()),
                          icon: const Icon(Icons.explore_outlined),
                          label: const Text('Découvrir des ressources'),
                        ),
                      )
                    else
                      for (final resource in filtered)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.small,
                          ),
                          child: LibraryResourceCard(
                            resource: resource,
                            isFavorite: state.favoriteIds.contains(resource.id),
                            trailing: IconButton(
                              tooltip: 'Retirer de ma bibliothèque',
                              onPressed: () => _removeResource(resource),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            onTap: () => context.push(
                              AppRoutes.libraryResourcePath(resource.id),
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<LibraryResource> _filterResources(
    List<LibraryResource> resources,
    LibraryLocalState state,
  ) {
    Iterable<LibraryResource> selected = switch (_filter) {
      _PersonalLibraryFilter.all => resources.where(
        (resource) => state.libraryIds.contains(resource.id),
      ),
      _PersonalLibraryFilter.books => resources.where(
        (resource) =>
            state.libraryIds.contains(resource.id) &&
            resource.type == LibraryResourceType.book,
      ),
      _PersonalLibraryFilter.documents => resources.where(
        (resource) =>
            state.libraryIds.contains(resource.id) &&
            resource.type != LibraryResourceType.book,
      ),
      _PersonalLibraryFilter.favorites => resources.where(
        (resource) => state.favoriteIds.contains(resource.id),
      ),
      _PersonalLibraryFilter.recent => resources.where(
        (resource) => state.lastOpenedAt.containsKey(resource.id),
      ),
      _PersonalLibraryFilter.downloads => resources.where(
        (resource) => state.downloadedIds.contains(resource.id),
      ),
      _PersonalLibraryFilter.collections => const [],
    };
    final query = _queryController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      selected = selected.where(
        (resource) =>
            resource.title.toLowerCase().contains(query) ||
            resource.author.toLowerCase().contains(query) ||
            resource.topics.any((topic) => topic.toLowerCase().contains(query)),
      );
    }
    final result = selected.toList();
    if (_filter == _PersonalLibraryFilter.recent) {
      result.sort(
        (first, second) => state.lastOpenedAt[second.id]!.compareTo(
          state.lastOpenedAt[first.id]!,
        ),
      );
    } else if (_filter == _PersonalLibraryFilter.downloads) {
      result.sort(
        (first, second) => (state.downloadedAt[second.id] ?? '').compareTo(
          state.downloadedAt[first.id] ?? '',
        ),
      );
    } else if (_sortAlphabetically) {
      result.sort((first, second) => first.title.compareTo(second.title));
    }
    return result;
  }

  Widget _collectionsContent(List<LibraryCollection> collections) {
    if (collections.isEmpty) {
      return AppEmptyState(
        title: 'Aucune collection personnelle',
        description: 'Créez une collection pour organiser vos ressources.',
        icon: Icons.collections_bookmark_outlined,
        action: FilledButton(
          onPressed: () => context.push(AppRoutes.libraryCollections),
          child: const Text('Créer une collection'),
        ),
      );
    }
    return Column(
      children: [
        for (final collection in collections)
          ListTile(
            leading: const Icon(Icons.collections_bookmark_outlined),
            title: Text(collection.name),
            subtitle: Text('${collection.resourceIds.length} ressources'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () =>
                context.push(AppRoutes.libraryCollectionPath(collection.id)),
          ),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.libraryCollections),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Gérer les collections'),
        ),
      ],
    );
  }

  Future<void> _removeResource(LibraryResource resource) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer de ma bibliothèque ?'),
        content: Text('« ${resource.title} » sera retiré de votre liste.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (remove != true || !mounted) return;
    try {
      await ref.read(libraryLocalStoreProvider).removeFromLibrary(resource.id);
      ref.invalidate(libraryLocalStateProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de retirer la ressource : $error')),
      );
    }
  }
}
