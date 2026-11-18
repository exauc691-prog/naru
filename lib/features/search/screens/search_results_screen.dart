import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_view.dart';
import '../models/search_models.dart';
import '../providers/search_providers.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.query,
    this.initialType,
  });

  final String query;
  final String? initialType;

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState
    extends ConsumerState<SearchResultsScreen> {
  SearchFilter _filter = const SearchFilter();
  SearchSort _sort = SearchSort.relevance;
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    if (widget.initialType == 'courses') {
      _filter = const SearchFilter(types: {SearchResultType.course});
      _selectedCategory = 'Cours';
    } else if (widget.initialType == 'library') {
      _filter = const SearchFilter(
        types: {
          SearchResultType.book,
          SearchResultType.document,
          SearchResultType.resource,
        },
      );
      _selectedCategory = 'Livres';
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(searchCatalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        actions: [
          IconButton(
            tooltip: 'Filtres',
            onPressed: _showFilters,
            icon: Icon(
              Icons.tune_rounded,
              color: _filter.isEmpty ? null : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Recherche en cours',
          ),
        ),
        error: (_, _) => AppErrorView(
          message: 'La recherche locale n’a pas pu être chargée.',
          onRetry: () => ref.invalidate(searchCatalogProvider),
        ),
        data: (items) {
          final results = ref.read(searchServiceProvider).search(
                catalog: items,
                query: widget.query,
                filter: _filter,
                sort: _sort,
              );
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${results.length} résultat${results.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      PopupMenuButton<SearchSort>(
                        onSelected: (value) =>
                            setState(() => _sort = value),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: SearchSort.relevance, child: Text('Pertinence')),
                          PopupMenuItem(value: SearchSort.recent, child: Text('Plus récent')),
                          PopupMenuItem(value: SearchSort.popular, child: Text('Plus populaire')),
                          PopupMenuItem(value: SearchSort.shortest, child: Text('Durée courte')),
                          PopupMenuItem(value: SearchSort.longest, child: Text('Durée longue')),
                          PopupMenuItem(value: SearchSort.alphabetical, child: Text('A-Z')),
                        ],
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sort_rounded),
                            SizedBox(width: AppSpacing.verySmall),
                            Text('Tri'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in const [
                          'Tous',
                          'Cours',
                          'Livres',
                          'Leçons',
                          'Documents',
                          'Exercices',
                          'Outils',
                        ])
                          Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.small),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (_) =>
                                  _selectCategory(category),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (results.isEmpty)
                    AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Aucun résultat trouvé',
                      description:
                          'Essayez un autre terme ou une catégorie plus générale.',
                      action: OutlinedButton(
                        onPressed: () => setState(() {
                          _filter = const SearchFilter();
                          _selectedCategory = 'Tous';
                        }),
                        child: const Text('Effacer les filtres'),
                      ),
                    )
                  else
                    for (final result in results)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: _SearchResultCard(result: result),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filter = _filter.copyWith(
        types: switch (category) {
          'Cours' => {SearchResultType.course},
          'Livres' => {SearchResultType.book},
          'Leçons' => {SearchResultType.lesson},
          'Documents' => {
              SearchResultType.document,
              SearchResultType.resource,
            },
          'Exercices' => {SearchResultType.exercise},
          'Outils' => {SearchResultType.tool},
          _ => <SearchResultType>{},
        },
      );
    });
  }

  Future<void> _showFilters() async {
    final next = await showModalBottomSheet<SearchFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SearchFilterSheet(initial: _filter),
    );
    if (next != null) setState(() => _filter = next);
  }
}

class _SearchFilterSheet extends StatefulWidget {
  const _SearchFilterSheet({required this.initial});

  final SearchFilter initial;

  @override
  State<_SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<_SearchFilterSheet> {
  late Set<SearchResultType> _types;
  late Set<SearchLevel> _levels;
  String? _duration;

  @override
  void initState() {
    super.initState();
    _types = {...widget.initial.types};
    _levels = {...widget.initial.levels};
    _duration = widget.initial.duration;
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.small,
        AppSpacing.large,
        AppSpacing.large,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filtres',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.medium),
            const Text('Type'),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                for (final type in SearchResultType.values)
                  FilterChip(
                    label: Text(type.label),
                    selected: _types.contains(type),
                    onSelected: (selected) => setState(() {
                      selected ? _types.add(type) : _types.remove(type);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            const Text('Niveau'),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              children: [
                for (final level in SearchLevel.values)
                  FilterChip(
                    label: Text(
                      switch (level) {
                        SearchLevel.beginner => 'Débutant',
                        SearchLevel.intermediate => 'Intermédiaire',
                        SearchLevel.advanced => 'Avancé',
                      },
                    ),
                    selected: _levels.contains(level),
                    onSelected: (selected) => setState(() {
                      selected ? _levels.add(level) : _levels.remove(level);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            DropdownButtonFormField<String>(
              initialValue: _duration,
              hint: const Text('Toutes les durées'),
              items: const [
                DropdownMenuItem(value: 'short', child: Text('Moins de 30 min')),
                DropdownMenuItem(value: 'medium', child: Text('30 min à 2 h')),
                DropdownMenuItem(value: 'long', child: Text('2 h à 5 h')),
                DropdownMenuItem(value: 'veryLong', child: Text('Plus de 5 h')),
              ],
              onChanged: (value) => setState(() => _duration = value),
            ),
            const SizedBox(height: AppSpacing.large),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _types.clear();
                      _levels.clear();
                      _duration = null;
                    }),
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      SearchFilter(
                        types: _types,
                        levels: _levels,
                        duration: _duration,
                      ),
                    ),
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: () => context.push(result.route),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onPrimaryContainer,
              child: Icon(result.icon),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.type.label,
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 2),
                  Text(result.title,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.verySmall),
                  Text(
                    result.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.verySmall,
                    children: [
                      Text(_levelLabel(result.level)),
                      Text(_durationLabel(result.durationMinutes)),
                      if (result.progress != null)
                        Text(
                            'En cours · ${(result.progress! * 100).round()} %'),
                      if (result.accessLabel != null)
                        Text(result.accessLabel!),
                      if (result.priceLabel != null)
                        Text(result.priceLabel!),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );

  static String _levelLabel(SearchLevel level) => switch (level) {
    SearchLevel.beginner => 'Débutant',
    SearchLevel.intermediate => 'Intermédiaire',
    SearchLevel.advanced => 'Avancé',
  };

  static String _durationLabel(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours h' : '$hours h $rest';
  }
}
