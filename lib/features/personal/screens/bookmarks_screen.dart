import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../library/providers/library_providers.dart';

class PersonalBookmarksScreen extends ConsumerStatefulWidget {
  const PersonalBookmarksScreen({super.key});

  @override
  ConsumerState<PersonalBookmarksScreen> createState() =>
      _PersonalBookmarksScreenState();
}

class _PersonalBookmarksScreenState
    extends ConsumerState<PersonalBookmarksScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryLocalStateProvider);
    final resources = ref.watch(libraryResourcesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes signets')),
      body: state.when(
        data: (local) {
          final query = _searchController.text.trim().toLowerCase();
          final entries = [
            for (final resource in resources)
              if (local.bookmarks[resource.id] != null)
                for (final page in local.bookmarks[resource.id]!)
                  (resource, page),
          ].where((entry) {
            return query.isEmpty ||
                entry.$1.title.toLowerCase().contains(query);
          }).toList();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un signet',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (entries.isEmpty)
                    const AppEmptyState(
                      icon: Icons.bookmark_border_rounded,
                      title: 'Aucun signet',
                      description:
                          'Ajoutez un signet depuis le lecteur d’une ressource.',
                    )
                  else
                    for (final entry in entries)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: AppCard(
                          onTap: () => context.push(
                            AppRoutes.libraryReaderPath(entry.$1.id),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bookmark_rounded),
                              const SizedBox(width: AppSpacing.medium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.$1.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    Text('Page ${entry.$2 + 1}'),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Impossible de charger les signets.')),
      ),
    );
  }
}
