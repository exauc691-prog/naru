import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../subscription/providers/subscription_providers.dart';
import '../../providers/assistant_providers.dart';
import '../../widgets/assistant_demo_banner.dart';
import '../../widgets/assistant_feedback.dart';

class AssistantVoiceScreen extends ConsumerStatefulWidget {
  const AssistantVoiceScreen({super.key});

  @override
  ConsumerState<AssistantVoiceScreen> createState() =>
      _AssistantVoiceScreenState();
}

class _AssistantVoiceScreenState extends ConsumerState<AssistantVoiceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _previewRunning = false;

  static const _sampleTranscript =
      'Texte d’exemple, non reconnu : « Explique-moi les bases de la programmation. »';

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _startPreview() async {
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .recordVoicePreview(_sampleTranscript);
      if (!mounted) return;
      setState(() => _previewRunning = true);
      _pulse.repeat(reverse: true);
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  void _stopPreview() {
    setState(() => _previewRunning = false);
    _pulse.stop();
    _pulse.reset();
  }

  Future<void> _showPlaybackNotice() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lecture vocale à venir'),
        content: const Text(
          'Aucun moteur de synthèse vocale n’est connecté. Aucun son ne sera '
          'généré ou lu par cette démonstration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assistant = ref.watch(assistantControllerProvider);
    final plan = ref.watch(subscriptionPlanProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant vocal'),
        actions: [
          IconButton(
            tooltip: 'Historique des conversations',
            onPressed: () => context.push(AppRoutes.assistantHistory),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: assistant.when(
            data: (state) => ListView(
              padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
              children: [
                const AssistantDemoBanner(),
                const SizedBox(height: AppSpacing.medium),
                plan.when(
                  data: (currentPlan) => Text(
                    '${currentPlan.name} · les fonctionnalités vocales réelles '
                    'ne sont pas encore connectées.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  error: (error, stack) => const SizedBox.shrink(),
                  loading: () => const LinearProgressIndicator(),
                ),
                const SizedBox(height: AppSpacing.large),
                AppCard(
                  child: Column(
                    children: [
                      Text(
                        _previewRunning ? 'Aperçu en cours' : 'Aperçu vocal',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        _previewRunning
                            ? 'Animation et texte prédéfinis — aucun microphone utilisé.'
                            : 'Explorez la présentation de l’interface, sans '
                                  'demande d’autorisation microphone.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.large),
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, child) => SizedBox(
                          height: 72,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (final factor in const [
                                0.35,
                                0.65,
                                1.0,
                                0.55,
                                0.8,
                                0.4,
                                0.7,
                              ])
                                Container(
                                  width: 7,
                                  height: _previewRunning
                                      ? 12 + 44 * factor * _pulse.value
                                      : 12,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      if (_previewRunning)
                        Text(_sampleTranscript, textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.medium),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSpacing.small,
                        runSpacing: AppSpacing.small,
                        children: [
                          if (!_previewRunning)
                            FilledButton.icon(
                              onPressed: _startPreview,
                              icon: const Icon(Icons.mic_none_rounded),
                              label: const Text('Lancer l’aperçu'),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: _stopPreview,
                              icon: const Icon(Icons.stop_rounded),
                              label: const Text('Arrêter l’aperçu'),
                            ),
                          OutlinedButton.icon(
                            onPressed: _showPlaybackNotice,
                            icon: const Icon(Icons.volume_up_outlined),
                            label: const Text('Tester la lecture'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                const SectionTitle(
                  title: 'Fonctionnalités prévues',
                  subtitle:
                      'Speech-to-Text, Text-to-Speech et conversation continue',
                ),
                const SizedBox(height: AppSpacing.small),
                const Text(
                  'La reconnaissance vocale et la lecture à voix haute '
                  'nécessiteront un moteur dédié et votre autorisation. '
                  'Aucune captation ou génération audio n’est réalisée ici.',
                ),
                const SizedBox(height: AppSpacing.large),
                const SectionTitle(title: 'Historique des aperçus'),
                const SizedBox(height: AppSpacing.small),
                if (state.voiceHistory.isEmpty)
                  const Text('Aucun aperçu vocal enregistré.')
                else
                  for (final entry in state.voiceHistory)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.exampleText),
                            const SizedBox(height: AppSpacing.small),
                            Text(
                              'Exemple non reconnu · '
                              '${MaterialLocalizations.of(context).formatShortDate(entry.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
            error: (error, stack) => const Center(
              child: Text('Impossible de charger l’historique vocal local.'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
