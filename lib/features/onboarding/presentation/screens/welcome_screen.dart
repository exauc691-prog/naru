import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/router/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _NaruBrand(),
                const SizedBox(height: AppSpacing.medium),
                const _WelcomeIllustration(),
                const SizedBox(height: AppSpacing.large),
                Text(
                  'Apprenez. Comprenez. Progressez.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Découvrez une nouvelle manière d’apprendre, développez '
                  'vos compétences et progressez à votre rythme grâce à un '
                  'accompagnement intelligent.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                AppButton(
                  label: 'Créer mon compte',
                  size: AppButtonSize.large,
                  isExpanded: true,
                  onPressed: () => context.go(AppRoutes.register),
                ),
                const SizedBox(height: AppSpacing.small),
                AppButton(
                  label: 'Se connecter',
                  variant: AppButtonVariant.text,
                  isExpanded: true,
                  onPressed: () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _NaruBrand extends StatelessWidget {
  const _NaruBrand();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: AppRadius.mediumBorderRadius,
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: scheme.primary,
            size: 25,
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Text('naru', style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1.55,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final iconSize = math.min(width * 0.26, 112.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: math.min(width * 0.52, 220.0),
                height: math.min(width * 0.52, 220.0),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: iconSize,
                  color: scheme.primary,
                ),
              ),
              Positioned(
                left: width * 0.03,
                top: height * 0.12,
                child: _LearningTag(
                  icon: Icons.code_rounded,
                  label: 'Programmation',
                  color: scheme.secondaryContainer,
                ),
              ),
              Positioned(
                right: width * 0.02,
                top: height * 0.2,
                child: _LearningTag(
                  icon: Icons.psychology_alt_rounded,
                  label: 'Nouvelles idées',
                  color: scheme.tertiaryContainer,
                ),
              ),
              Positioned(
                left: width * 0.16,
                bottom: height * 0.08,
                child: _LearningTag(
                  icon: Icons.trending_up_rounded,
                  label: 'À votre rythme',
                  color: scheme.surfaceContainerHighest,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LearningTag extends StatelessWidget {
  const _LearningTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.small,
      vertical: AppSpacing.small,
    ),
    backgroundColor: color,
    showBorder: false,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.verySmall),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    ),
  );
}
