import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../models/assistant_conversation.dart';
import '../../models/assistant_mode.dart';
import '../../models/assistant_state.dart';
import '../../providers/assistant_providers.dart';
import '../../widgets/assistant_demo_banner.dart';
import '../../widgets/assistant_feedback.dart';

class AssistantHistoryScreen extends ConsumerStatefulWidget {
  const AssistantHistoryScreen({super.key});

  @override
  ConsumerState<AssistantHistoryScreen> createState() =>
      _AssistantHistoryScreenState();
}

class _AssistantHistoryScreenState
    extends ConsumerState<AssistantHistoryScreen> {
  final _searchController = TextEditingController();
  String _category = 'Toutes';
  bool _favoritesOnly = false;

  static const _categories = [
    'Toutes',
    'Études',
    'Programmation',
    'Rédaction',
    'Documents',
    'Autres',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _rename(AssistantConversation conversation) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) =>
          _RenameConversationDialog(initialTitle: conversation.title),
    );
    if (title == null || !mounted) return;
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .renameConversation(conversation.id, title);
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  Future<void> _delete(AssistantConversation conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette conversation ?'),
        content: const Text(
          'Cette action retire la conversation de l’historique local.',
        ),
        actions: [
          IconButton(
            tooltip: 'Favoris',
            onPressed: () => context.push(AppRoutes.assistantFavorites),
            icon: const Icon(Icons.bookmarks_outlined),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .deleteConversation(conversation.id);
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  Future<void> _toggleFavorite(String conversationId) async {
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .toggleFavorite(conversationId);
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assistant = ref.watch(assistantControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            tooltip: 'Nouvelle conversation',
            onPressed: () => context.push(AppRoutes.assistant),
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: assistant.when(
        data: (state) {
          final filtered = _filter(state);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
                children: [
                  const AssistantDemoBanner(),
                  const SizedBox(height: AppSpacing.medium),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une conversation',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Effacer la recherche',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in _categories)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.small,
                            ),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: _category == category,
                              onSelected: (_) =>
                                  setState(() => _category = category),
                            ),
                          ),
                        FilterChip(
                          label: const Text('Favoris'),
                          selected: _favoritesOnly,
                          onSelected: (value) =>
                              setState(() => _favoritesOnly = value),
                          avatar: const Icon(Icons.star_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    '${filtered.length} conversation(s) · triées par activité récente',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  if (filtered.isEmpty)
                    AppEmptyState(
                      icon: Icons.forum_outlined,
                      title: state.conversations.isEmpty
                          ? 'Votre historique est vide'
                          : 'Aucun résultat',
                      description: state.conversations.isEmpty
                          ? 'Les conversations de démonstration apparaîtront ici.'
                          : 'Essayez un autre mot-clé ou une autre catégorie.',
                      action: state.conversations.isEmpty
                          ? FilledButton.icon(
                              onPressed: () =>
                                  context.push(AppRoutes.assistant),
                              icon: const Icon(Icons.add_comment_outlined),
                              label: const Text('Démarrer une conversation'),
                            )
                          : null,
                    )
                  else
                    for (final conversation in filtered)
                      _ConversationCard(
                        conversation: conversation,
                        onOpen: () => context.push(
                          AppRoutes.assistantConversationPath(conversation.id),
                        ),
                        onFavorite: () => _toggleFavorite(conversation.id),
                        onRename: () => _rename(conversation),
                        onDelete: () => _delete(conversation),
                      ),
                ],
              ),
            ),
          );
        },
        error: (error, stack) => const Center(
          child: Text('Impossible de charger l’historique local.'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  List<AssistantConversation> _filter(AssistantState state) {
    final query = _searchController.text.trim().toLowerCase();
    final results = state.conversations.where((conversation) {
      final matchesQuery =
          query.isEmpty ||
          conversation.title.toLowerCase().contains(query) ||
          conversation.messages.any(
            (message) => message.content.toLowerCase().contains(query),
          );
      final matchesCategory =
          _category == 'Toutes' || conversation.mode.category == _category;
      final matchesFavorite = !_favoritesOnly || conversation.isFavorite;
      return matchesQuery && matchesCategory && matchesFavorite;
    }).toList();
    results.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return results;
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.onOpen,
    required this.onFavorite,
    required this.onRename,
    required this.onDelete,
  });

  final AssistantConversation conversation;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: AppCard(
      onTap: onOpen,
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline_rounded),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.verySmall),
                Text(
                  '${conversation.mode.category} · ${conversation.mode.label} · '
                  '${conversation.messages.length} messages',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: conversation.isFavorite
                ? 'Retirer des favoris'
                : 'Ajouter aux favoris',
            onPressed: onFavorite,
            icon: Icon(
              conversation.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  onRename();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'rename', child: Text('Modifier le titre')),
              PopupMenuItem(value: 'delete', child: Text('Supprimer')),
            ],
          ),
        ],
      ),
    ),
  );
}

class _RenameConversationDialog extends StatefulWidget {
  const _RenameConversationDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameConversationDialog> createState() =>
      _RenameConversationDialogState();
}

class _RenameConversationDialogState extends State<_RenameConversationDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Modifier le titre'),
    content: TextField(controller: _controller, autofocus: true, maxLength: 60),
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
