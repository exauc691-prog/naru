import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../subscription/models/subscription_plan.dart';
import '../../../subscription/widgets/feature_upgrade_dialog.dart';
import '../../models/assistant_document.dart';
import '../../providers/assistant_providers.dart';
import '../../widgets/assistant_demo_banner.dart';
import '../../widgets/assistant_feedback.dart';

class AssistantDocumentsScreen extends ConsumerStatefulWidget {
  const AssistantDocumentsScreen({super.key});

  @override
  ConsumerState<AssistantDocumentsScreen> createState() =>
      _AssistantDocumentsScreenState();
}

class _AssistantDocumentsScreenState
    extends ConsumerState<AssistantDocumentsScreen> {
  final _questionController = TextEditingController();

  static const _examples = <(String, String, String)>[
    ('Guide-de-revision.pdf', 'PDF', '1,2 Mo'),
    ('Notes-de-cours.txt', 'TXT', '4 Ko'),
    ('Fiche-de-synthese.docx', 'DOCX', '820 Ko'),
    ('Schema-de-cours.png', 'Image', '640 Ko'),
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _addExample((String, String, String) example) async {
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .addDocument(
            name: example.$1,
            format: example.$2,
            sizeLabel: example.$3,
          );
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  Future<void> _showPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.medium),
          children: [
            Text(
              'Exemples de documents',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Maquette uniquement : aucun fichier réel n’est sélectionné, '
              'ouvert ou envoyé.',
            ),
            const SizedBox(height: AppSpacing.medium),
            for (final example in _examples)
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(example.$1),
                subtitle: Text('${example.$2} · ${example.$3}'),
                onTap: () {
                  Navigator.pop(context);
                  _addExample(example);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _prepareAction(String action) async {
    final assistant = ref.read(assistantControllerProvider).asData?.value;
    if (assistant == null || assistant.documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez d’abord un exemple de document.'),
        ),
      );
      return;
    }
    if (!await requireSubscriptionFeature(
      context,
      ref,
      SubscriptionFeature.assistantDocumentTools,
    )) {
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action · aperçu indisponible'),
        content: Text(
          '« ${assistant.documents.first.name} » est une entrée de '
          'démonstration. Aucun contenu n’a été lu ni analysé. '
          'La connexion au backend sera nécessaire pour traiter les documents.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Future<void> _askQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saisissez une question sur le document.'),
        ),
      );
      return;
    }
    await _prepareAction('Question sur le document');
  }

  Future<void> _remove(AssistantDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer cet élément ?'),
        content: Text(
          '${document.name} sera retiré de la liste locale de démonstration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .deleteDocument(document.id);
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            tooltip: 'Historique des conversations',
            onPressed: () => context.push(AppRoutes.assistantHistory),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: state.when(
        data: (assistant) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
              children: [
                const AssistantDemoBanner(),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Préparez vos documents pour de futures fonctionnalités '
                  'd’analyse. La sélection et le traitement réels ne sont '
                  'pas encore connectés.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.large),
                FilledButton.icon(
                  onPressed: _showPicker,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Ajouter un exemple de document'),
                ),
                const SizedBox(height: AppSpacing.large),
                SectionTitle(
                  title: 'Documents de démonstration',
                  subtitle: '${assistant.documents.length} élément(s)',
                ),
                const SizedBox(height: AppSpacing.small),
                if (assistant.documents.isEmpty)
                  const AppCard(
                    child: Text(
                      'Aucun document. Ajoutez un exemple pour explorer '
                      'l’interface sans envoyer de fichier.',
                    ),
                  )
                else
                  for (final document in assistant.documents)
                    _DocumentCard(
                      document: document,
                      onDelete: () => _remove(document),
                    ),
                const SizedBox(height: AppSpacing.large),
                const SectionTitle(title: 'Actions préparées'),
                const SizedBox(height: AppSpacing.small),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    for (final action in [
                      'Résumer',
                      'Expliquer',
                      'Extraire les idées',
                      'Créer une fiche',
                    ])
                      OutlinedButton(
                        onPressed: () => _prepareAction(action),
                        child: Text(action),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _questionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Question sur le document',
                    hintText: 'Saisissez votre question…',
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _askQuestion,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Préparer la question'),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                const SectionTitle(title: 'Historique des documents ajoutés'),
                const SizedBox(height: AppSpacing.small),
                if (assistant.documents.isEmpty)
                  const Text('Les exemples ajoutés apparaîtront ici.')
                else
                  for (final document in assistant.documents)
                    ListTile(
                      leading: const Icon(Icons.history_rounded),
                      title: Text(document.name),
                      subtitle: Text(
                        'Ajouté localement · '
                        '${MaterialLocalizations.of(context).formatShortDate(document.addedAt)}',
                      ),
                    ),
              ],
            ),
          ),
        ),
        error: (error, stack) => const Center(
          child: Text('Impossible de charger la liste locale des documents.'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, required this.onDelete});

  final AssistantDocument document;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: AppCard(
      child: Row(
        children: [
          const Icon(Icons.description_outlined),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${document.format} · ${document.sizeLabel} · exemple, non analysé',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Retirer ${document.name}',
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    ),
  );
}
