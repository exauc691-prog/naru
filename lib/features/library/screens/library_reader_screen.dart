import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/widgets/feature_upgrade_dialog.dart';
import '../data/library_local_store.dart';
import '../models/library_resource.dart';
import '../providers/library_providers.dart';

class LibraryReaderScreen extends ConsumerStatefulWidget {
  const LibraryReaderScreen({super.key, required this.resourceId});

  final String resourceId;

  @override
  ConsumerState<LibraryReaderScreen> createState() =>
      _LibraryReaderScreenState();
}

class _LibraryReaderScreenState extends ConsumerState<LibraryReaderScreen> {
  final _scrollController = ScrollController();
  double _textSize = 18;
  double _lineSpacing = 1.65;
  bool _darkReadingSurface = false;
  bool _serifFont = false;
  int? _activePage;

  @override
  void didUpdateWidget(covariant LibraryReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resourceId != widget.resourceId) {
      _activePage = null;
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resource = ref.watch(libraryResourceByIdProvider(widget.resourceId));
    final local = ref.watch(libraryLocalStateProvider);
    final plan = ref.watch(subscriptionPlanProvider);
    if (resource == null) {
      return const SafeArea(
        child: AppEmptyState(
          title: 'Ressource introuvable',
          description: 'Ce document ne figure pas dans le catalogue.',
          icon: Icons.menu_book_outlined,
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: local.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'La position de lecture ne peut pas être chargée.',
          onRetry: () => ref.invalidate(libraryLocalStateProvider),
        ),
        data: (state) => plan.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => AppErrorView(
            message: 'La formule actuelle ne peut pas être vérifiée.',
            onRetry: () => ref.invalidate(subscriptionPlanProvider),
          ),
          data: (currentPlan) {
            if (!resource.distributionAuthorized) {
              return const AppEmptyState(
                title: 'Lecture indisponible',
                description:
                    'La distribution de ce contenu n’est pas autorisée.',
                icon: Icons.lock_outline_rounded,
              );
            }
            if (!canAccessLibraryResource(currentPlan, resource)) {
              final feature = requiredLibraryFeature(resource);
              return AppEmptyState(
                title: 'Ressource ${resource.availability.label}',
                description:
                    'Cette lecture nécessite une formule supérieure. '
                    'Le contenu reste consultable après activation de l’accès.',
                icon: Icons.lock_outline_rounded,
                action: feature == null
                    ? AppButton(
                        label: 'Retour au détail',
                        isExpanded: true,
                        onPressed: () => context.pop(),
                      )
                    : AppButton(
                        label: 'Découvrir ${feature.requiredPlan.name}',
                        isExpanded: true,
                        onPressed: () =>
                            requireSubscriptionFeature(context, ref, feature),
                      ),
              );
            }
            final pages = resource.content;
            if (pages.isEmpty) {
              return const AppEmptyState(
                title: 'Aucun contenu de démonstration',
                description: 'Cette ressource ne contient pas encore de texte.',
                icon: Icons.article_outlined,
              );
            }
            final page = (_activePage ?? state.readingPages[resource.id] ?? 0)
                .clamp(0, pages.length - 1)
                .toInt();
            _activePage = page;
            if (state.readingPages[resource.id] != page) {
              _recordPage(resource.id, page);
            }
            return _reader(context, resource, state, page);
          },
        ),
      ),
    );
  }

  Widget _reader(
    BuildContext context,
    LibraryResource resource,
    LibraryLocalState state,
    int page,
  ) {
    final pages = resource.content;
    final currentPage = pages[page];
    final bookmarked = state.bookmarks[resource.id]?.contains(page) ?? false;
    final surface = _darkReadingSurface
        ? const Color(0xFF202124)
        : Theme.of(context).colorScheme.surfaceContainerLow;
    final textColor = _darkReadingSurface
        ? const Color(0xFFF2F0EA)
        : Theme.of(context).colorScheme.onSurface;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.small,
                vertical: AppSpacing.verySmall,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Retour au détail',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      resource.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: bookmarked
                        ? 'Retirer le signet'
                        : 'Ajouter un signet',
                    onPressed: () => _toggleBookmark(resource.id, page),
                    icon: Icon(
                      bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Options de lecture',
                    onSelected: (value) {
                      switch (value) {
                        case 'settings':
                          _showReadingSettings();
                        case 'bookmarks':
                          _showBookmarks(resource.id, pages.length);
                        case 'note':
                          _showNote(
                            resource.id,
                            state.notes[resource.id] ?? '',
                          );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'settings',
                        child: Text('Paramètres de lecture'),
                      ),
                      PopupMenuItem(
                        value: 'bookmarks',
                        child: Text('Consulter les signets'),
                      ),
                      PopupMenuItem(
                        value: 'note',
                        child: Text('Prendre une note'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.large,
                vertical: AppSpacing.small,
              ),
              child: Column(
                children: [
                  LinearProgressIndicator(value: (page + 1) / pages.length),
                  const SizedBox(height: AppSpacing.verySmall),
                  Text('Page ${page + 1} sur ${pages.length}'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  AppSpacing.small,
                  AppSpacing.medium,
                  AppSpacing.large,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      backgroundColor: surface,
                      padding: const EdgeInsets.all(AppSpacing.large),
                      child: SelectionArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPage.heading,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: textColor),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            for (final paragraph in currentPage.paragraphs)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.medium,
                                ),
                                child: SelectableText(
                                  paragraph,
                                  style: TextStyle(
                                    fontSize: _textSize,
                                    height: _lineSpacing,
                                    color: textColor,
                                    fontFamily: _serifFont ? 'serif' : null,
                                  ),
                                ),
                              ),
                            Text(
                              'Contenu textuel fictif · ${resource.format.label}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: textColor.withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    AppCard(
                      child: Text(
                        'Lecture de démonstration : aucun fichier PDF ou EPUB '
                        'protégé ni téléchargement distant n’est ouvert.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.small,
                AppSpacing.medium,
                AppSpacing.medium,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: page == 0
                          ? null
                          : () => _setPage(resource.id, page - 1),
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Précédente'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: page == pages.length - 1
                          ? null
                          : () => _setPage(resource.id, page + 1),
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: const Text('Suivante'),
                      iconAlignment: IconAlignment.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordPage(String resourceId, int page) async {
    try {
      await ref.read(libraryLocalStoreProvider).recordOpened(resourceId, page);
      ref.invalidate(libraryLocalStateProvider);
    } catch (error) {
      if (mounted) _showMessage('Impossible d’enregistrer la lecture : $error');
    }
  }

  Future<void> _setPage(String resourceId, int page) async {
    setState(() => _activePage = page);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    await _recordPage(resourceId, page);
  }

  Future<void> _toggleBookmark(String resourceId, int page) async {
    try {
      await ref
          .read(libraryLocalStoreProvider)
          .toggleBookmark(resourceId, page);
      ref.invalidate(libraryLocalStateProvider);
    } catch (error) {
      if (mounted) _showMessage('Impossible d’enregistrer le signet : $error');
    }
  }

  Future<void> _showBookmarks(String resourceId, int pageCount) async {
    final state = await ref.read(libraryLocalStateProvider.future);
    if (!mounted) return;
    final pages = state.bookmarks[resourceId] ?? const <int>[];
    if (pages.isEmpty) {
      _showMessage('Aucun signet enregistré pour ce document.');
      return;
    }
    final selectedPage = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Signets'),
        children: [
          for (final page in pages.where((value) => value < pageCount))
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, page),
              child: Text('Page ${page + 1}'),
            ),
        ],
      ),
    );
    if (selectedPage != null) await _setPage(resourceId, selectedPage);
  }

  Future<void> _showNote(String resourceId, String savedNote) async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => _ReaderNoteDialog(initialValue: savedNote),
    );
    if (note == null) return;
    try {
      await ref.read(libraryLocalStoreProvider).saveNote(resourceId, note);
      ref.invalidate(libraryLocalStateProvider);
      if (mounted) _showMessage('Note enregistrée sur cet appareil.');
    } catch (error) {
      if (mounted) _showMessage('Impossible d’enregistrer la note : $error');
    }
  }

  Future<void> _showReadingSettings() => showModalBottomSheet<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, updateSheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paramètres de lecture',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text('Taille du texte : ${_textSize.round()}'),
              Slider(
                min: 14,
                max: 26,
                divisions: 6,
                value: _textSize,
                onChanged: (value) {
                  updateSheet(() => _textSize = value);
                  setState(() => _textSize = value);
                },
              ),
              Text('Espacement : ${_lineSpacing.toStringAsFixed(1)}'),
              Slider(
                min: 1.2,
                max: 2.2,
                divisions: 5,
                value: _lineSpacing,
                onChanged: (value) {
                  updateSheet(() => _lineSpacing = value);
                  setState(() => _lineSpacing = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _darkReadingSurface,
                title: const Text('Fond sombre'),
                onChanged: (value) {
                  updateSheet(() => _darkReadingSurface = value);
                  setState(() => _darkReadingSurface = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _serifFont,
                title: const Text('Police avec empattements'),
                onChanged: (value) {
                  updateSheet(() => _serifFont = value);
                  setState(() => _serifFont = value);
                },
              ),
              const SizedBox(height: AppSpacing.small),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Terminé'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReaderNoteDialog extends StatefulWidget {
  const _ReaderNoteDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_ReaderNoteDialog> createState() => _ReaderNoteDialogState();
}

class _ReaderNoteDialogState extends State<_ReaderNoteDialog> {
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
    title: const Text('Note de lecture'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      minLines: 3,
      maxLines: 6,
      decoration: const InputDecoration(
        hintText: 'Votre note personnelle…',
        border: OutlineInputBorder(),
      ),
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
