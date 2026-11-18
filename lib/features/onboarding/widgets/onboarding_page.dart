import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../data/onboarding_content.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.content, super.key});

  final OnboardingContent content;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final illustrationHeight = (constraints.maxHeight * 0.43)
          .clamp(170.0, 280.0)
          .toDouble();

      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                  vertical: AppSpacing.medium,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: illustrationHeight,
                      width: double.infinity,
                      child: _OnboardingIllustration(
                        illustration: content.illustration,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      content.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      content.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.illustration});

  final OnboardingIllustration illustration;

  @override
  Widget build(BuildContext context) => switch (illustration) {
    OnboardingIllustration.learningDomains => const _DomainsIllustration(),
    OnboardingIllustration.learningProgress => const _ProgressIllustration(),
    OnboardingIllustration.learningAssistant => const _AssistantIllustration(),
  };
}

class _DomainsIllustration extends StatelessWidget {
  const _DomainsIllustration();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topics = [
      (Icons.code_rounded, 'Code', scheme.primaryContainer),
      (Icons.smart_toy_outlined, 'IA', scheme.secondaryContainer),
      (Icons.science_outlined, 'Sciences', scheme.tertiaryContainer),
      (Icons.translate_rounded, 'Langues', scheme.surfaceContainerHighest),
      (Icons.devices_rounded, 'Technologie', scheme.primaryContainer),
    ];

    return _IllustrationFrame(
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: topics
              .map(
                (topic) => _TopicTile(
                  icon: topic.$1,
                  label: topic.$2,
                  backgroundColor: topic.$3,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.icon,
    required this.label,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.small,
      vertical: AppSpacing.medium,
    ),
    backgroundColor: backgroundColor,
    showBorder: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: AppSpacing.verySmall),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );
}

class _ProgressIllustration extends StatelessWidget {
  const _ProgressIllustration();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _IllustrationFrame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 320;
          return Center(
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: compact
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ProgressRing(
                              size: 64,
                              backgroundColor: scheme.surfaceContainerHighest,
                            ),
                            const SizedBox(width: AppSpacing.small),
                            Flexible(
                              child: Text(
                                'Votre parcours',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.small),
                        _ProgressLine(
                          label: 'Leçons',
                          value: 0.72,
                          color: scheme.primary,
                          width: 176,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        _ProgressLine(
                          label: 'Exercices',
                          value: 0.48,
                          color: scheme.secondary,
                          width: 176,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ProgressRing(
                          size: 104,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Votre parcours',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.small),
                            _ProgressLine(
                              label: 'Leçons',
                              value: 0.72,
                              color: scheme.primary,
                            ),
                            const SizedBox(height: AppSpacing.small),
                            _ProgressLine(
                              label: 'Exercices',
                              value: 0.48,
                              color: scheme.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.size, required this.backgroundColor});

  final double size;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: 0.72,
          strokeWidth: 9,
          strokeCap: StrokeCap.round,
          backgroundColor: backgroundColor,
        ),
        Text('72%', style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.label,
    required this.value,
    required this.color,
    this.width = 112,
  });

  final String label;
  final double value;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: AppSpacing.verySmall),
      SizedBox(
        width: width,
        child: LinearProgressIndicator(
          value: value,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
          color: color,
        ),
      ),
    ],
  );
}

class _AssistantIllustration extends StatelessWidget {
  const _AssistantIllustration();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 220 || constraints.maxWidth < 320;
      final scheme = Theme.of(context).colorScheme;

      return _IllustrationFrame(
        child: Center(
          child: AppCard(
            padding: EdgeInsets.all(
              compact ? AppSpacing.small : AppSpacing.medium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: compact ? 16 : 20,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.primary,
                      child: const Icon(Icons.auto_awesome_rounded),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Flexible(
                      child: Text(
                        compact ? 'Assistant IA' : 'Votre assistant',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: compact ? AppSpacing.small : AppSpacing.medium,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ChatBubble(
                    color: scheme.surfaceContainerHighest,
                    maxWidth: compact ? 176 : 250,
                    text: compact
                        ? 'Explique les fonctions.'
                        : 'Peux-tu m’expliquer les fonctions ?',
                  ),
                ),
                SizedBox(
                  height: compact ? AppSpacing.verySmall : AppSpacing.small,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _ChatBubble(
                    color: scheme.primaryContainer,
                    maxWidth: compact ? 176 : 250,
                    text: compact
                        ? 'Des blocs réutilisables.'
                        : 'Bien sûr. Commençons par un exemple simple.',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.color,
    required this.text,
    required this.maxWidth,
  });

  final Color color;
  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.mediumBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.small),
        child: Text(text, style: Theme.of(context).textTheme.bodySmall),
      ),
    ),
  );
}

class _IllustrationFrame extends StatelessWidget {
  const _IllustrationFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: AppRadius.cardBorderRadius,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: child,
    ),
  );
}
