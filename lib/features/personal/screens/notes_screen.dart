import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/personal_content_models.dart';
import '../providers/personal_providers.dart';

class PersonalNotesScreen extends ConsumerStatefulWidget {
  const PersonalNotesScreen({super.key});

  @override
  ConsumerState<PersonalNotesScreen> createState() =>
      _PersonalNotesScreenState();
}

class _PersonalNotesScreenState
    extends ConsumerState<PersonalNotesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(personalNotesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        actions: [
          IconButton(
            tooltip: 'Créer une note',
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: state.when(
        data: (notes) {
          final query = _searchController.text.trim().toLowerCase();
          final filtered = notes.where((note) {
            return query.isEmpty ||
                note.title.toLowerCase().contains(query) ||
                note.content.toLowerCase().contains(query) ||
                note.source.toLowerCase().contains(query);
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
                      hintText: 'Rechercher dans les notes',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (filtered.isEmpty)
                    AppEmptyState(
                      icon: Icons.note_alt_outlined,
                      title: query.isEmpty
                          ? 'Aucune note pour le moment'
                          : 'Aucune note trouvée',
                      description: query.isEmpty
                          ? 'Écrivez les idées importantes à retrouver rapidement.'
                          : 'Essayez un autre mot-clé.',
                      action: query.isEmpty
                          ? FilledButton.icon(
                              onPressed: () => _openEditor(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Créer une note'),
                            )
                          : null,
                    )
                  else
                    for (final note in filtered)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: AppCard(
                          onTap: () => _openEditor(note: note),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(note.title,
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: AppSpacing.verySmall),
                              Text(
                                note.content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                'Source : ${note.source}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
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
            const Center(child: Text('Impossible de charger les notes.')),
      ),
    );
  }

  Future<void> _openEditor({PersonalNote? note}) async {
    final result = await showModalBottomSheet<_NoteEditorResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _NoteEditor(note: note),
    );
    if (result == null) return;
    if (result.delete && note != null) {
      await ref.read(personalNotesProvider.notifier).delete(note.id);
      return;
    }
    if (note == null) {
      await ref.read(personalNotesProvider.notifier).create(
            title: result.title,
            content: result.content,
            source: result.source,
          );
    } else {
      await ref.read(personalNotesProvider.notifier).editNote(
            note,
            title: result.title,
            content: result.content,
            source: result.source,
          );
    }
  }
}

class _NoteEditorResult {
  const _NoteEditorResult({
    this.title = '',
    this.content = '',
    this.source = 'Naru',
    this.delete = false,
  });

  final String title;
  final String content;
  final String source;
  final bool delete;
}

class _NoteEditor extends StatefulWidget {
  const _NoteEditor({this.note});

  final PersonalNote? note;

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _source;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note?.title);
    _content = TextEditingController(text: widget.note?.content);
    _source = TextEditingController(text: widget.note?.source ?? 'Naru');
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: AppSpacing.large,
      right: AppSpacing.large,
      top: AppSpacing.small,
      bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.large,
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.note == null ? 'Nouvelle note' : 'Modifier la note',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Titre'),
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _source,
            decoration: const InputDecoration(labelText: 'Source'),
          ),
          const SizedBox(height: AppSpacing.small),
          TextField(
            controller: _content,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Contenu',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              if (widget.note != null)
                IconButton(
                  tooltip: 'Supprimer la note',
                  onPressed: () => Navigator.pop(
                    context,
                    const _NoteEditorResult(delete: true),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              const SizedBox(width: AppSpacing.small),
              FilledButton(
                onPressed: _content.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(
                          context,
                          _NoteEditorResult(
                            title: _title.text,
                            content: _content.text,
                            source: _source.text,
                          ),
                        ),
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
