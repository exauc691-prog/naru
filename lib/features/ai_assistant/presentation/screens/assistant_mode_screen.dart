import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../subscription/models/subscription_plan.dart';
import '../../../subscription/widgets/feature_upgrade_dialog.dart';
import '../../data/assistant_quota_config.dart';
import '../../models/assistant_mode.dart';
import '../../providers/assistant_providers.dart';
import '../../widgets/assistant_composer.dart';
import '../../widgets/assistant_demo_banner.dart';
import '../../widgets/assistant_feedback.dart';

class AssistantModeScreen extends ConsumerStatefulWidget {
  const AssistantModeScreen({required this.mode, super.key});

  final AssistantMode mode;

  @override
  ConsumerState<AssistantModeScreen> createState() =>
      _AssistantModeScreenState();
}

class _AssistantModeScreenState extends ConsumerState<AssistantModeScreen> {
  String _language = 'Dart';
  String _sourceLanguage = 'Français';
  String _targetLanguage = 'Anglais';

  static const _programmingLanguages = [
    'Dart',
    'Flutter',
    'Python',
    'Go',
    'JavaScript',
    'SQL',
    'Autre',
  ];

  static const _languages = [
    'Français',
    'Anglais',
    'Espagnol',
    'Allemand',
    'Italien',
    'Portugais',
    'Arabe',
    'Japonais',
  ];

  Future<bool> _send(String text) async {
    try {
      if (widget.mode == AssistantMode.programming &&
          !await requireSubscriptionFeature(
            context,
            ref,
            SubscriptionFeature.assistantProgrammingTools,
          )) {
        return false;
      }

      final prompt = switch (widget.mode) {
        AssistantMode.programming => 'Langage : $_language\n\n$text',
        AssistantMode.translation =>
          'Traduction de $_sourceLanguage vers $_targetLanguage :\n$text',
        _ => text,
      };
      final id = await ref
          .read(assistantControllerProvider.notifier)
          .startConversation(mode: widget.mode, content: prompt);
      if (mounted) context.push(AppRoutes.assistantConversationPath(id));
      return true;
    } on AssistantQuotaExceeded catch (error) {
      if (mounted) await showAssistantQuotaDialog(context, ref, error);
      return false;
    } catch (error) {
      if (mounted) showAssistantError(context, error);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assistant = ref.watch(assistantControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.mode.label)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
                  children: [
                    Text(
                      widget.mode.description,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    const AssistantDemoBanner(),
                    const SizedBox(height: AppSpacing.large),
                    if (widget.mode == AssistantMode.programming)
                      _languageSelector(
                        label: 'Langage de programmation',
                        value: _language,
                        values: _programmingLanguages,
                        onChanged: (value) => setState(() => _language = value),
                      ),
                    if (widget.mode == AssistantMode.translation) ...[
                      _languageSelector(
                        label: 'Langue source',
                        value: _sourceLanguage,
                        values: _languages,
                        onChanged: (value) =>
                            setState(() => _sourceLanguage = value),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      _languageSelector(
                        label: 'Langue cible',
                        value: _targetLanguage,
                        values: _languages,
                        onChanged: (value) =>
                            setState(() => _targetLanguage = value),
                      ),
                    ],
                    if (widget.mode == AssistantMode.homework)
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push(AppRoutes.assistantDocuments),
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Préparer une image d’exercice'),
                      ),
                    if (widget.mode == AssistantMode.learn) ...[
                      const SizedBox(height: AppSpacing.medium),
                      const _ModeTip(
                        icon: Icons.lightbulb_outline_rounded,
                        text:
                            'Demandez une explication, un exemple ou une question '
                            'pour vérifier votre compréhension.',
                      ),
                    ],
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      'Décrivez votre besoin',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              AssistantComposer(
                onSend: _send,
                onAttachment: () => context.push(AppRoutes.assistantDocuments),
                onVoice: () => context.push(AppRoutes.assistantVoice),
                hintText: _hintForMode(widget.mode),
                isEnabled: assistant.hasValue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageSelector({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.medium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final language in values)
              ChoiceChip(
                label: Text(language),
                selected: value == language,
                onSelected: (_) => onChanged(language),
              ),
          ],
        ),
      ],
    ),
  );
}

String _hintForMode(AssistantMode mode) => switch (mode) {
  AssistantMode.learn => 'Que souhaitez-vous apprendre ?',
  AssistantMode.homework => 'Décrivez l’exercice et ce que vous avez essayé…',
  AssistantMode.writing => 'Décrivez le texte ou vos idées…',
  AssistantMode.documents => 'Posez une question sur un document…',
  AssistantMode.programming => 'Décrivez le code ou le concept à explorer…',
  AssistantMode.translation => 'Saisissez le texte à traduire…',
  AssistantMode.organization => 'Quel projet ou objectif organiser ?',
};

class _ModeTip extends StatelessWidget {
  const _ModeTip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.medium),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: AppSpacing.small),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
