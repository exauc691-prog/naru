import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/widgets/feature_upgrade_dialog.dart';
import '../data/library_local_store.dart';
import '../models/library_collection.dart';
import '../models/library_resource.dart';
import '../providers/library_providers.dart';
import '../widgets/library_resource_card.dart';

class LibraryResourceDetailScreen extends ConsumerWidget {
  const LibraryResourceDetailScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resource = ref.watch(libraryResourceByIdProvider(resourceId));
    final local = ref.watch(libraryLocalStateProvider);
    final plan = ref.watch(subscriptionPlanProvider);
    if (resource == null) {
      return const SafeArea(
        child: AppEmptyState(
          title: 'Ressource introuvable',
          description:
              'Cette ressource n’est pas disponible dans le catalogue.',
          icon: Icons.menu_book_outlined,
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: local.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message:
              'Les préférences de la bibliothèque ne peuvent pas être lues.',
          onRetry: () => ref.invalidate(libraryLocalStateProvider),
        ),
        data: (state) => plan.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => AppErrorView(
            message: 'La formule actuelle ne peut pas être vérifiée.',
            onRetry: () => ref.invalidate(subscriptionPlanProvider),
          ),
          data: (currentPlan) => Center(
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
                        tooltip: 'Retour au catalogue',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'Détail de la ressource',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Center(
                    child: LibraryResourceCover(
                      resource: resource,
                      width: 154,
                      height: 208,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    resource.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.verySmall),
                  Text(
                    resource.author,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: [
                      Chip(label: Text(libraryResourceCategoryName(resource))),
                      Chip(label: Text(resource.availability.label)),
                      Chip(label: Text(resource.type.label)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    resource.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _MetadataCard(resource: resource),
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle(title: 'Ce que vous allez découvrir'),
                  const SizedBox(height: AppSpacing.small),
                  for (final topic in resource.topics)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline_rounded),
                      title: Text(topic),
                    ),
                  const SizedBox(height: AppSpacing.section),
                  if (resource.availability ==
                      LibraryAvailability.individualPurchase)
                    AppCard(
                      child: Text(
                        'Cette ressource est destinée à une future vente '
                        'individuelle. Aucun achat ni paiement n’est disponible '
                        'dans cette démonstration.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else if (!resource.distributionAuthorized)
                    const AppCard(
                      child: Text(
                        'La distribution de cette ressource n’est pas autorisée.',
                      ),
                    )
                  else if (!canAccessLibraryResource(currentPlan, resource))
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accès ${resource.availability.label}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            'Cette ressource est incluse avec la formule '
                            '${_requiredPlanName(resource)}. Vous pouvez la '
                            'conserver dans vos favoris, mais la lecture est '
                            'réservée aux membres admissibles.',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.medium),
                  if (resource.distributionAuthorized &&
                      resource.availability !=
                          LibraryAvailability.individualPurchase)
                    AppButton(
                      label: 'Lire maintenant',
                      icon: Icons.menu_book_rounded,
                      isExpanded: true,
                      onPressed: () =>
                          _openReader(context, ref, resource, currentPlan),
                    )
                  else if (resource.distributionAuthorized)
                    AppButton(
                      label: 'Obtenir cette ressource',
                      icon: Icons.shopping_bag_outlined,
                      isExpanded: true,
                      onPressed: () => _showUnavailablePurchase(context),
                    ),
                  const SizedBox(height: AppSpacing.small),
                  AppButton(
                    label: state.libraryIds.contains(resource.id)
                        ? 'Retirer de ma bibliothèque'
                        : 'Ajouter à ma bibliothèque',
                    variant: AppButtonVariant.outlined,
                    icon: state.libraryIds.contains(resource.id)
                        ? Icons.remove_circle_outline
                        : Icons.library_add_outlined,
                    isExpanded: true,
                    onPressed: () => _updateLibrary(
                      context,
                      ref,
                      resource,
                      state.libraryIds,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _toggleFavorite(
                          context,
                          ref,
                          resource,
                          state.favoriteIds,
                        ),
                        icon: Icon(
                          state.favoriteIds.contains(resource.id)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                        ),
                        label: Text(
                          state.favoriteIds.contains(resource.id)
                              ? 'Retirer des favoris'
                              : 'Ajouter aux favoris',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _addToCollection(context, ref, resource),
                        icon: const Icon(Icons.collections_bookmark_outlined),
                        label: const Text('Ajouter à une collection'),
                      ),
                      if (resource.isDownloadable &&
                          resource.distributionAuthorized &&
                          resource.availability !=
                              LibraryAvailability.individualPurchase)
                        OutlinedButton.icon(
                          onPressed: () => _toggleDownload(
                            context,
                            ref,
                            resource,
                            currentPlan,
                            state.downloadedIds.contains(resource.id),
                          ),
                          icon: Icon(
                            state.downloadedIds.contains(resource.id)
                                ? Icons.download_done_rounded
                                : Icons.download_outlined,
                          ),
                          label: Text(
                            state.downloadedIds.contains(resource.id)
                                ? 'Retirer le téléchargement'
                                : 'Télécharger',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openReader(
    BuildContext context,
    WidgetRef ref,
    LibraryResource resource,
    SubscriptionPlan plan,
  ) async {
    if (!resource.distributionAuthorized) {
      _showMessage(
        context,
        'La distribution de cette ressource n’est pas autorisée.',
      );
      return;
    }
    if (!canAccessLibraryResource(plan, resource)) {
      final feature = requiredLibraryFeature(resource);
      if (feature != null) {
        await requireSubscriptionFeature(context, ref, feature);
      } else {
        _showUnavailablePurchase(context);
      }
      return;
    }
    if (!context.mounted) return;
    context.push(AppRoutes.libraryReaderPath(resource.id));
  }

  Future<void> _updateLibrary(
    BuildContext context,
    WidgetRef ref,
    LibraryResource resource,
    Set<String> libraryIds,
  ) async {
    try {
      final store = ref.read(libraryLocalStoreProvider);
      if (libraryIds.contains(resource.id)) {
        await store.removeFromLibrary(resource.id);
      } else {
        await store.addToLibrary(resource.id);
      }
      ref.invalidate(libraryLocalStateProvider);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Impossible de modifier la bibliothèque : $error');
    }
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    LibraryResource resource,
    Set<String> favoriteIds,
  ) async {
    try {
      await ref.read(libraryLocalStoreProvider).toggleFavorite(resource.id);
      ref.invalidate(libraryLocalStateProvider);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Impossible de modifier les favoris : $error');
    }
  }

  Future<void> _toggleDownload(
    BuildContext context,
    WidgetRef ref,
    LibraryResource resource,
    SubscriptionPlan plan,
    bool downloaded,
  ) async {
    if (!canAccessLibraryResource(plan, resource)) {
      final feature = requiredLibraryFeature(resource);
      if (feature != null) {
        await requireSubscriptionFeature(context, ref, feature);
      }
      return;
    }
    try {
      await ref
          .read(libraryLocalStoreProvider)
          .setDownloaded(resource.id, !downloaded);
      if (!context.mounted) return;
      ref.invalidate(libraryLocalStateProvider);
      _showMessage(
        context,
        downloaded
            ? 'Téléchargement de démonstration retiré.'
            : 'Ressource ajoutée aux téléchargements simulés.',
      );
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(
        context,
        'Impossible de modifier le téléchargement : $error',
      );
    }
  }

  Future<void> _addToCollection(
    BuildContext context,
    WidgetRef ref,
    LibraryResource resource,
  ) async {
    late final LibraryLocalState state;
    try {
      state = await ref.read(libraryLocalStateProvider.future);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Impossible de charger les collections : $error');
      return;
    }
    if (!context.mounted) return;
    if (state.collections.isEmpty) {
      _showMessage(context, 'Créez d’abord une collection personnelle.');
      context.push(AppRoutes.libraryCollections);
      return;
    }
    final collection = await showDialog<LibraryCollection>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Ajouter à une collection'),
        children: [
          for (final item in state.collections)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item),
              child: Text(item.name),
            ),
        ],
      ),
    );
    if (collection == null || !context.mounted) return;
    try {
      await ref
          .read(libraryLocalStoreProvider)
          .addResourceToCollection(collection.id, resource.id);
      if (!context.mounted) return;
      ref.invalidate(libraryLocalStateProvider);
      _showMessage(context, 'Ressource ajoutée à « ${collection.name} ».');
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Impossible de modifier la collection : $error');
    }
  }

  void _showUnavailablePurchase(BuildContext context) => _showMessage(
    context,
    'L’achat individuel sera disponible ultérieurement. Aucun paiement n’est effectué.',
  );

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.resource});

  final LibraryResource resource;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        _MetadataRow(
          label: 'Catégorie',
          value: libraryResourceCategoryName(resource),
        ),
        _MetadataRow(label: 'Pages', value: '${resource.pages ?? 'Inconnu'}'),
        _MetadataRow(label: 'Langue', value: resource.language),
        _MetadataRow(label: 'Format', value: resource.format.label),
        _MetadataRow(
          label: 'Publication',
          value: _dateLabel(resource.publishedAt),
        ),
        if (resource.publisher != null)
          _MetadataRow(label: 'Éditeur', value: resource.publisher!),
        if (resource.difficulty != null)
          _MetadataRow(label: 'Niveau', value: resource.difficulty!),
        _MetadataRow(label: 'Droits', value: resource.rights.label),
        if (resource.individualPriceInCents case final price?)
          _MetadataRow(
            label: 'Prix indicatif',
            value: '${_priceLabel(price)} · aucun paiement connecté',
          ),
        _MetadataRow(label: 'Titulaire', value: resource.rightsHolder),
        _MetadataRow(
          label: 'Distribution',
          value: resource.distributionAuthorized
              ? 'Autorisée'
              : 'Non autorisée',
        ),
        if (resource.licenseDetails != null)
          _MetadataRow(label: 'Licence', value: resource.licenseDetails!),
      ],
    ),
  );
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.verySmall),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

String _requiredPlanName(LibraryResource resource) {
  final feature = requiredLibraryFeature(resource);
  return feature?.requiredPlan.name ?? 'une formule payante';
}

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

String _priceLabel(int priceInCents) {
  final whole = priceInCents ~/ 100;
  final cents = (priceInCents % 100).toString().padLeft(2, '0');
  return '$whole,$cents \$';
}
