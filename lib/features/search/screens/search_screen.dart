import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/search_mock_data.dart';
import '../providers/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = '', this.initialType});

  final String initialQuery;
  final String? initialType;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    FocusScope.of(context).unfocus();
    ref.read(searchHistoryProvider.notifier).add(normalized);
    context.push(
      Uri(
        path: AppRoutes.searchResults,
        queryParameters: {
          'query': normalized,
          if (widget.initialType != null) 'type': widget.initialType!,
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryProvider);
    final catalog = ref.watch(searchCatalogProvider);
    final suggestions = catalog.when(
      data: (items) => ref.read(searchServiceProvider).suggest(
            _controller.text,
            [
              for (final item in items) item.title,
              ...popularSearches,
            ],
          ),
      loading: () => const <String>[],
      error: (_, _) => const <String>[],
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: widget.initialQuery.isEmpty,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
          onSubmitted: _submit,
          decoration: const InputDecoration(
            hintText: 'Rechercher un cours, un livre, une notion...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
            children: [
              if (_controller.text.trim().isNotEmpty) ...[
                Text('Suggestions',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.small),
                if (suggestions.isEmpty)
                  const Text('Appuyez sur Entrée pour lancer la recherche.')
                else
                  for (final suggestion in suggestions)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.search_rounded),
                      title: Text(suggestion),
                      trailing: const Icon(Icons.north_west_rounded),
                      onTap: () {
                        _controller.text = suggestion;
                        _submit(suggestion);
                      },
                    ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text('Recherches récentes',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(searchHistoryProvider.notifier).clear(),
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
                history.when(
                  data: (items) => items.isEmpty
                      ? const Text('Vos recherches apparaîtront ici.')
                      : Column(
                          children: [
                            for (final item in items)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.history_rounded),
                                title: Text(item.query),
                                trailing: IconButton(
                                  tooltip: 'Supprimer cette recherche',
                                  onPressed: () => ref
                                      .read(searchHistoryProvider.notifier)
                                      .delete(item.id),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                                onTap: () => _submit(item.query),
                              ),
                          ],
                        ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) =>
                      const Text('L’historique local est indisponible.'),
                ),
                const SizedBox(height: AppSpacing.large),
                Text('Recherches populaires',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.small),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    for (final query in popularSearches)
                      ActionChip(
                        label: Text(query),
                        onPressed: () => _submit(query),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
