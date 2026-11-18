import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../library/providers/library_providers.dart';
import '../providers/personal_providers.dart';

class PersonalLibraryScreen extends ConsumerWidget {
  const PersonalLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryLocalStateProvider);
    final notes = ref.watch(personalNotesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes contenus')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
              children: [
                Text(
                  'Retrouvez ici ce que vous avez enregistré.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.large),
                library.when(
                  data: (state) => Column(
                    children: [
                      _PersonalTile(
                        icon: Icons.favorite_border_rounded,
                        title: 'Favoris',
                        count: state.favoriteIds.length,
                        onTap: () => context.push(AppRoutes.myLibrary),
                      ),
                      _PersonalTile(
                        icon: Icons.collections_bookmark_outlined,
                        title: 'Collections',
                        count: state.collections.length,
                        onTap: () =>
                            context.push(AppRoutes.libraryCollections),
                      ),
                      _PersonalTile(
                        icon: Icons.bookmark_border_rounded,
                        title: 'Signets',
                        count: state.bookmarks.values
                            .fold<int>(0, (sum, pages) => sum + pages.length),
                        onTap: () =>
                            context.push(AppRoutes.personalBookmarks),
                      ),
                      _PersonalTile(
                        icon: Icons.download_outlined,
                        title: 'Téléchargements',
                        count: state.downloadedIds.length,
                        onTap: () =>
                            context.push(AppRoutes.libraryDownloads),
                      ),
                      _PersonalTile(
                        icon: Icons.history_rounded,
                        title: 'Récents',
                        count: state.lastOpenedAt.length,
                        onTap: () => context.push(AppRoutes.myLibrary),
                      ),
                      notes.when(
                        data: (items) => _PersonalTile(
                          icon: Icons.note_alt_outlined,
                          title: 'Notes',
                          count: items.length,
                          onTap: () => context.push(AppRoutes.personalNotes),
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) =>
                      const Text('Vos contenus locaux ne peuvent pas être chargés.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalTile extends StatelessWidget {
  const _PersonalTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          Text('$count',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: AppSpacing.small),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}
