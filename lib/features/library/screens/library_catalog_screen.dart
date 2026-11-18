import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../data/library_catalog_filters.dart';
import '../models/library_resource.dart';
import '../providers/library_providers.dart';
import '../widgets/library_resource_card.dart';

class LibraryCatalogScreen extends ConsumerStatefulWidget {
  const LibraryCatalogScreen({
    super.key,
    this.initialQuery = '',
    this.initialCategoryId,
    this.initialType,
    this.initialSort,
    this.collectionId,
  });

  final String initialQuery;
  final String? initialCategoryId;
  final String? initialType;
  final String? initialSort;
  final String? collectionId;

  @override
  ConsumerState<LibraryCatalogScreen> createState() =>
      _LibraryCatalogScreenState();
}

class _LibraryCatalogScreenState extends ConsumerState<LibraryCatalogScreen> {
  late final TextEditingController _queryController;
  final _scrollController = ScrollController();
  String? _categoryId;
  LibraryResourceType? _type;
  LibraryAvailability? _availability;
  LibraryResourceSort _sort = LibraryResourceSort.recent;
  bool _documentsOnly = false;
  bool _gridView = true;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    _categoryId = widget.initialCategoryId;
    _documentsOnly = widget.initialType == 'documents';
    if (widget.initialType == 'books') _type = LibraryResourceType.book;
    _sort = _sortFromName(widget.initialSort);
  }

  @override
  void didUpdateWidget(covariant LibraryCatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery ||
        oldWidget.initialCategoryId != widget.initialCategoryId ||
        oldWidget.initialType != widget.initialType ||
        oldWidget.initialSort != widget.initialSort) {
      _queryController.text = widget.initialQuery;
      _categoryId = widget.initialCategoryId;
      _documentsOnly = widget.initialType == 'documents';
      _type = widget.initialType == 'books' ? LibraryResourceType.book : null;
      _sort = _sortFromName(widget.initialSort);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resources = ref.watch(libraryResourcesProvider);
    final local = ref.watch(libraryLocalStateProvider);
    final title = widget.collectionId == null
        ? 'Explorer les ressources'
        : 'Ajouter à une collection';

    return SafeArea(
      bottom: false,
      child: local.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: 'Le catalogue ne peut pas charger vos préférences locales.',
          onRetry: () => ref.invalidate(libraryLocalStateProvider),
        ),
        data: (state) {
          final visibleResources = filterLibraryResources(
            resources: resources.where(
              (resource) =>
                  !_documentsOnly || resource.type != LibraryResourceType.book,
            ),
            query: _queryController.text,
            categoryId: _categoryId,
            type: _type,
            availability: _availability,
            sort: _sort,
          );
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                controller: _scrollController,
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
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: _gridView
                            ? 'Afficher en liste'
                            : 'Afficher en grille',
                        onPressed: () => setState(() => _gridView = !_gridView),
                        icon: Icon(
                          _gridView
                              ? Icons.view_list_rounded
                              : Icons.grid_view_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: _queryController,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un livre ou un document...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _queryController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Effacer la recherche',
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
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _showFilters,
                        icon: const Icon(Icons.tune_rounded),
                        label: Text(
                          _activeFilterCount == 0
                              ? 'Filtres'
                              : 'Filtres ($_activeFilterCount)',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.small),
                      Expanded(
                        child: PopupMenuButton<LibraryResourceSort>(
                          tooltip: 'Trier les ressources',
                          onSelected: (value) => setState(() => _sort = value),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: LibraryResourceSort.recent,
                              child: Text('Plus récents'),
                            ),
                            PopupMenuItem(
                              value: LibraryResourceSort.popular,
                              child: Text('Plus populaires'),
                            ),
                            PopupMenuItem(
                              value: LibraryResourceSort.alphabetical,
                              child: Text('Alphabétique'),
                            ),
                            PopupMenuItem(
                              value: LibraryResourceSort.rating,
                              child: Text('Mieux notés'),
                            ),
                          ],
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.small,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sort_rounded),
                                const SizedBox(width: AppSpacing.small),
                                Expanded(
                                  child: Text(
                                    _sortLabel(_sort),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_categoryId != null ||
                      _type != null ||
                      _availability != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.small),
                      child: Wrap(
                        spacing: AppSpacing.small,
                        children: [
                          if (_categoryId != null)
                            InputChip(
                              label: Text(
                                libraryCategories[_categoryId] ?? _categoryId!,
                              ),
                              onDeleted: () =>
                                  setState(() => _categoryId = null),
                            ),
                          if (_type != null || _documentsOnly)
                            InputChip(
                              label: Text(
                                _documentsOnly ? 'Documents' : _type!.label,
                              ),
                              onDeleted: () => setState(() {
                                _type = null;
                                _documentsOnly = false;
                              }),
                            ),
                          if (_availability != null)
                            InputChip(
                              label: Text(_availability!.label),
                              onDeleted: () =>
                                  setState(() => _availability = null),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.medium),
                  SectionTitle(
                    title: '${visibleResources.length} ressources',
                    subtitle: 'Contenus fictifs de démonstration',
                  ),
                  const SizedBox(height: AppSpacing.small),
                  if (visibleResources.isEmpty)
                    const AppEmptyState(
                      title: 'Aucune ressource trouvée',
                      description:
                          'Essayez un autre terme ou retirez certains filtres.',
                      icon: Icons.search_off_rounded,
                    )
                  else if (_gridView)
                    LayoutBuilder(
                      builder: (context, constraints) => GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visibleResources.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth >= 560 ? 3 : 2,
                          crossAxisSpacing: AppSpacing.small,
                          mainAxisSpacing: AppSpacing.small,
                          childAspectRatio: constraints.maxWidth >= 560
                              ? 0.58
                              : 0.42,
                        ),
                        itemBuilder: (context, index) => _resourceCard(
                          visibleResources[index],
                          state.favoriteIds.contains(
                            visibleResources[index].id,
                          ),
                        ),
                      ),
                    )
                  else
                    for (final resource in visibleResources)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: _resourceCard(
                          resource,
                          state.favoriteIds.contains(resource.id),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int get _activeFilterCount =>
      (_categoryId == null ? 0 : 1) +
      (_type == null && !_documentsOnly ? 0 : 1) +
      (_availability == null ? 0 : 1);

  Widget _resourceCard(LibraryResource resource, bool isFavorite) =>
      LibraryResourceCard(
        resource: resource,
        isGrid: _gridView,
        isFavorite: isFavorite,
        onTap: widget.collectionId == null
            ? () => context.push(AppRoutes.libraryResourcePath(resource.id))
            : () => _addToCollection(resource),
      );

  Future<void> _addToCollection(LibraryResource resource) async {
    try {
      await ref
          .read(libraryLocalStoreProvider)
          .addResourceToCollection(widget.collectionId!, resource.id);
      if (!mounted) return;
      ref.invalidate(libraryLocalStateProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('« ${resource.title} » ajouté à la collection.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d’ajouter cette ressource : $error'),
        ),
      );
    }
  }

  Future<void> _showFilters() async {
    final selection = await showModalBottomSheet<_CatalogFilterSelection>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CatalogFilterSheet(
        categoryId: _categoryId,
        type: _type,
        documentsOnly: _documentsOnly,
        availability: _availability,
      ),
    );
    if (selection == null || !mounted) return;
    setState(() {
      _categoryId = selection.categoryId;
      _type = selection.type;
      _documentsOnly = selection.documentsOnly;
      _availability = selection.availability;
    });
  }
}

class _CatalogFilterSelection {
  const _CatalogFilterSelection({
    required this.categoryId,
    required this.type,
    required this.documentsOnly,
    required this.availability,
  });

  final String? categoryId;
  final LibraryResourceType? type;
  final bool documentsOnly;
  final LibraryAvailability? availability;
}

class _CatalogFilterSheet extends StatefulWidget {
  const _CatalogFilterSheet({
    required this.categoryId,
    required this.type,
    required this.documentsOnly,
    required this.availability,
  });

  final String? categoryId;
  final LibraryResourceType? type;
  final bool documentsOnly;
  final LibraryAvailability? availability;

  @override
  State<_CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState extends State<_CatalogFilterSheet> {
  late String _categoryId;
  late String _type;
  late String _availability;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId ?? '';
    _type = widget.documentsOnly ? 'documents' : widget.type?.name ?? 'all';
    _availability = widget.availability?.name ?? 'all';
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.large,
        AppSpacing.large,
        AppSpacing.large + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filtrer les ressources',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.medium),
          DropdownButtonFormField<String>(
            initialValue: _categoryId,
            decoration: const InputDecoration(
              labelText: 'Catégorie',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('Toutes les catégories'),
              ),
              for (final entry in libraryCategories.entries)
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            ],
            onChanged: (value) => setState(() => _categoryId = value ?? ''),
          ),
          const SizedBox(height: AppSpacing.medium),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Type de ressource',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: 'all',
                child: Text('Tous les types'),
              ),
              const DropdownMenuItem(
                value: 'documents',
                child: Text('Documents'),
              ),
              for (final type in LibraryResourceType.values)
                DropdownMenuItem(value: type.name, child: Text(type.label)),
            ],
            onChanged: (value) => setState(() => _type = value ?? 'all'),
          ),
          const SizedBox(height: AppSpacing.medium),
          DropdownButtonFormField<String>(
            initialValue: _availability,
            decoration: const InputDecoration(
              labelText: 'Disponibilité',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: 'all', child: Text('Toutes')),
              for (final availability in LibraryAvailability.values)
                DropdownMenuItem(
                  value: availability.name,
                  child: Text(availability.label),
                ),
            ],
            onChanged: (value) =>
                setState(() => _availability = value ?? 'all'),
          ),
          const SizedBox(height: AppSpacing.large),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              _CatalogFilterSelection(
                categoryId: _categoryId.isEmpty ? null : _categoryId,
                type: _type == 'all' || _type == 'documents'
                    ? null
                    : LibraryResourceType.values.byName(_type),
                documentsOnly: _type == 'documents',
                availability: _availability == 'all'
                    ? null
                    : LibraryAvailability.values.byName(_availability),
              ),
            ),
            child: const Text('Appliquer les filtres'),
          ),
        ],
      ),
    ),
  );
}

LibraryResourceSort _sortFromName(String? name) => switch (name) {
  'popular' => LibraryResourceSort.popular,
  'alphabetical' => LibraryResourceSort.alphabetical,
  'rating' => LibraryResourceSort.rating,
  _ => LibraryResourceSort.recent,
};

String _sortLabel(LibraryResourceSort sort) => switch (sort) {
  LibraryResourceSort.recent => 'Plus récents',
  LibraryResourceSort.popular => 'Populaires',
  LibraryResourceSort.alphabetical => 'Alphabétique',
  LibraryResourceSort.rating => 'Mieux notés',
};
