import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../models/library_resource.dart';
import '../providers/library_providers.dart';
import '../widgets/library_resource_card.dart';

class LibraryHomeScreen extends ConsumerWidget {
  const LibraryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = ref.watch(libraryLocalStateProvider);
    final resources = ref.watch(libraryResourcesProvider);
    return SafeArea(
      bottom: false,
      child: local.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: 'La bibliothèque personnelle ne peut pas être chargée.',
          onRetry: () => ref.invalidate(libraryLocalStateProvider),
        ),
        data: (state) {
          final recentlyOpened =
              resources
                  .where(
                    (resource) => state.lastOpenedAt.containsKey(resource.id),
                  )
                  .toList()
                ..sort(
                  (first, second) => state.lastOpenedAt[second.id]!.compareTo(
                    state.lastOpenedAt[first.id]!,
                  ),
                );
          final resumeResource = recentlyOpened.isEmpty
              ? null
              : recentlyOpened.first;
          final recommended = resources
              .where((resource) => resource.type == LibraryResourceType.book)
              .take(3)
              .toList();
          final popularDocuments =
              resources
                  .where(
                    (resource) => resource.type != LibraryResourceType.book,
                  )
                  .toList()
                ..sort(
                  (first, second) =>
                      second.popularity.compareTo(first.popularity),
                );
          final latest = resources.where((resource) => resource.isNew).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.horizontalMargin,
                  AppSpacing.large,
                  AppSpacing.horizontalMargin,
                  AppSpacing.veryLarge,
                ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bibliothèque',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.verySmall),
                            Text(
                              'Explorez, découvrez et enrichissez vos connaissances.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Rechercher des ressources',
                        onPressed: () =>
                            context.push(AppRoutes.libraryCatalogPath()),
                        icon: const Icon(Icons.search_rounded),
                      ),
                      IconButton(
                        tooltip: 'Notifications',
                        onPressed: () => context.push(AppRoutes.notifications),
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.large),
                  _HomeLibrarySearch(
                    onSearch: (query) => context.push(
                      AppRoutes.libraryCatalogPath(query: query),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  SectionTitle(
                    title: 'Reprendre ma lecture',
                    trailing: TextButton(
                      onPressed: () => context.push(AppRoutes.myLibrary),
                      child: const Text('Ma bibliothèque'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  if (resumeResource == null)
                    AppCard(
                      child: Row(
                        children: [
                          const Icon(Icons.auto_stories_outlined, size: 32),
                          const SizedBox(width: AppSpacing.medium),
                          Expanded(
                            child: Text(
                              'Votre prochaine lecture vous attend. '
                              'Explorez les ressources disponibles.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Explorer les ressources',
                            onPressed: () =>
                                context.push(AppRoutes.libraryCatalogPath()),
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ],
                      ),
                    )
                  else
                    _ResumeCard(
                      resource: resumeResource,
                      page: state.readingPages[resumeResource.id] ?? 0,
                      onContinue: () => context.push(
                        AppRoutes.libraryReaderPath(resumeResource.id),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.section),
                  SectionTitle(
                    title: 'Explorer les catégories',
                    trailing: TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.libraryCatalogPath()),
                      child: const Text('Voir tout'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: [
                      for (final entry in libraryCategories.entries)
                        ActionChip(
                          label: Text(entry.value),
                          onPressed: () => context.push(
                            AppRoutes.libraryCatalogPath(categoryId: entry.key),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.section),
                  _ResourceSection(
                    title: 'Livres recommandés',
                    resources: recommended,
                    onSeeAll: () =>
                        context.push(AppRoutes.libraryCatalogPath()),
                    onOpen: (resource) => context.push(
                      AppRoutes.libraryResourcePath(resource.id),
                    ),
                    favoriteIds: state.favoriteIds,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  _ResourceSection(
                    title: 'Documents populaires',
                    resources: popularDocuments.take(3).toList(),
                    onSeeAll: () => context.push(
                      AppRoutes.libraryCatalogPath(type: 'documents'),
                    ),
                    onOpen: (resource) => context.push(
                      AppRoutes.libraryResourcePath(resource.id),
                    ),
                    favoriteIds: state.favoriteIds,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  _ResourceSection(
                    title: 'Nouveautés',
                    resources: latest,
                    onSeeAll: () => context.push(
                      AppRoutes.libraryCatalogPath(sort: 'recent'),
                    ),
                    onOpen: (resource) => context.push(
                      AppRoutes.libraryResourcePath(resource.id),
                    ),
                    favoriteIds: state.favoriteIds,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  SectionTitle(
                    title: 'Collections',
                    trailing: TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.libraryCollections),
                      child: const Text('Voir tout'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  if (state.collections.isEmpty)
                    AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.collections_bookmark_outlined,
                        ),
                        title: const Text('Créez votre première collection'),
                        subtitle: const Text(
                          'Regroupez les ressources par sujet ou par objectif.',
                        ),
                        trailing: const Icon(Icons.arrow_forward_rounded),
                        onTap: () => context.push(AppRoutes.libraryCollections),
                      ),
                    )
                  else
                    for (final collection in state.collections.take(3))
                      AppCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.small),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.collections_bookmark_outlined,
                          ),
                          title: Text(collection.name),
                          subtitle: Text(
                            '${collection.resourceIds.length} ressources',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push(
                            AppRoutes.libraryCollectionPath(collection.id),
                          ),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.medium),
                  _QuickLinks(
                    onMyLibrary: () => context.push(AppRoutes.myLibrary),
                    onDownloads: () => context.push(AppRoutes.libraryDownloads),
                    onCollections: () =>
                        context.push(AppRoutes.libraryCollections),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({
    required this.resource,
    required this.page,
    required this.onContinue,
  });

  final LibraryResource resource;
  final int page;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        LibraryResourceCover(resource: resource, width: 64, height: 88),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resource.title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                resource.author,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.small),
              LinearProgressIndicator(
                value: ((page + 1) / resource.content.length)
                    .clamp(0.0, 1.0)
                    .toDouble(),
              ),
              const SizedBox(height: AppSpacing.verySmall),
              Text('Page ${page + 1} · ${resource.content.length}'),
              TextButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Continuer'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ResourceSection extends StatelessWidget {
  const _ResourceSection({
    required this.title,
    required this.resources,
    required this.onSeeAll,
    required this.onOpen,
    required this.favoriteIds,
  });

  final String title;
  final List<LibraryResource> resources;
  final VoidCallback onSeeAll;
  final ValueChanged<LibraryResource> onOpen;
  final Set<String> favoriteIds;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SectionTitle(
        title: title,
        trailing: TextButton(
          onPressed: onSeeAll,
          child: const Text('Voir tout'),
        ),
      ),
      const SizedBox(height: AppSpacing.small),
      for (final resource in resources)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.small),
          child: LibraryResourceCard(
            resource: resource,
            isFavorite: favoriteIds.contains(resource.id),
            onTap: () => onOpen(resource),
          ),
        ),
      if (resources.isEmpty) const Text('Aucune ressource pour le moment.'),
    ],
  );
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({
    required this.onMyLibrary,
    required this.onDownloads,
    required this.onCollections,
  });

  final VoidCallback onMyLibrary;
  final VoidCallback onDownloads;
  final VoidCallback onCollections;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.small,
    runSpacing: AppSpacing.small,
    children: [
      OutlinedButton.icon(
        onPressed: onMyLibrary,
        icon: const Icon(Icons.library_books_outlined),
        label: const Text('Ma bibliothèque'),
      ),
      OutlinedButton.icon(
        onPressed: onDownloads,
        icon: const Icon(Icons.download_outlined),
        label: const Text('Téléchargements'),
      ),
      OutlinedButton.icon(
        onPressed: onCollections,
        icon: const Icon(Icons.collections_bookmark_outlined),
        label: const Text('Collections'),
      ),
    ],
  );
}

class _HomeLibrarySearch extends StatefulWidget {
  const _HomeLibrarySearch({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  State<_HomeLibrarySearch> createState() => _HomeLibrarySearchState();
}

class _HomeLibrarySearchState extends State<_HomeLibrarySearch> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    textInputAction: TextInputAction.search,
    onSubmitted: widget.onSearch,
    decoration: InputDecoration(
      hintText: 'Rechercher un livre ou un document...',
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: IconButton(
        tooltip: 'Rechercher',
        onPressed: () => widget.onSearch(_controller.text),
        icon: const Icon(Icons.arrow_forward_rounded),
      ),
      border: const OutlineInputBorder(),
    ),
  );
}
