import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../models/library_resource.dart';
import '../providers/library_providers.dart';
import '../widgets/library_resource_card.dart';

class LibraryDownloadsScreen extends ConsumerStatefulWidget {
  const LibraryDownloadsScreen({super.key});

  @override
  ConsumerState<LibraryDownloadsScreen> createState() =>
      _LibraryDownloadsScreenState();
}

class _LibraryDownloadsScreenState
    extends ConsumerState<LibraryDownloadsScreen> {
  final _queryController = TextEditingController();

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
          message: 'Les téléchargements simulés ne peuvent pas être chargés.',
          onRetry: () => ref.invalidate(libraryLocalStateProvider),
        ),
        data: (state) {
          final query = _queryController.text.trim().toLowerCase();
          final downloaded =
              resources
                  .where(
                    (resource) => state.downloadedIds.contains(resource.id),
                  )
                  .where(
                    (resource) =>
                        query.isEmpty ||
                        resource.title.toLowerCase().contains(query) ||
                        resource.author.toLowerCase().contains(query),
                  )
                  .toList()
                ..sort(
                  (first, second) => (state.downloadedAt[second.id] ?? '')
                      .compareTo(state.downloadedAt[first.id] ?? ''),
                );
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
                        tooltip: 'Retour à ma bibliothèque',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'Téléchargements',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  const AppCard(
                    child: Text(
                      'Les fichiers et tailles affichés sont simulés. Aucun '
                      'transfert distant ni fichier hors ligne réel n’est créé.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: _queryController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un téléchargement',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (downloaded.isEmpty)
                    AppEmptyState(
                      title: 'Aucun téléchargement simulé',
                      description:
                          'Ajoutez une ressource accessible depuis sa fiche '
                          'pour la retrouver ici.',
                      icon: Icons.download_for_offline_outlined,
                      action: FilledButton.icon(
                        onPressed: () =>
                            context.push(AppRoutes.libraryCatalogPath()),
                        icon: const Icon(Icons.explore_outlined),
                        label: const Text('Explorer les ressources'),
                      ),
                    )
                  else ...[
                    Text(
                      '${downloaded.length} ressource${downloaded.length > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    for (final resource in downloaded)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: Column(
                          children: [
                            LibraryResourceCard(
                              resource: resource,
                              onTap: () => context.push(
                                AppRoutes.libraryReaderPath(resource.id),
                              ),
                              trailing: IconButton(
                                tooltip: 'Retirer le téléchargement simulé',
                                onPressed: () => _removeDownload(resource),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 100,
                                top: AppSpacing.verySmall,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.offline_pin_outlined,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppSpacing.verySmall),
                                  Expanded(
                                    child: Text(
                                      '${resource.fileSizeLabel ?? 'Taille inconnue'} · '
                                      '${resource.format.label} · '
                                      '${_dateLabel(state.downloadedAt[resource.id])}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push(
                                      AppRoutes.libraryReaderPath(resource.id),
                                    ),
                                    child: const Text('Ouvrir'),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Future<void> _removeDownload(LibraryResource resource) async {
    try {
      await ref
          .read(libraryLocalStoreProvider)
          .setDownloaded(resource.id, false);
      ref.invalidate(libraryLocalStateProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de retirer le téléchargement : $error'),
        ),
      );
    }
  }
}

String _dateLabel(String? value) {
  final date = value == null ? null : DateTime.tryParse(value)?.toLocal();
  if (date == null) return 'Date inconnue';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
