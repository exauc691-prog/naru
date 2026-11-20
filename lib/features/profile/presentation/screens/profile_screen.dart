import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../subscription/providers/subscription_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(subscriptionPlanProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
              children: [
                const CircleAvatar(
                  radius: 38,
                  child: Icon(Icons.person_rounded, size: 38),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'Samira Naru',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.verySmall),
                Text(
                  'samira@naru.app',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.large),
                plan.when(
                  data: (value) => AppCard(
                    child: Text('Formule actuelle : ${value.name}'),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                  loading: () => const LinearProgressIndicator(),
                ),
                const SizedBox(height: AppSpacing.large),
                _ProfileAction(
                  icon: Icons.folder_shared_outlined,
                  label: 'Mes contenus',
                  onTap: () => context.push(AppRoutes.personalContents),
                ),
                _ProfileAction(
                  icon: Icons.person_outline_rounded,
                  label: 'Mon profil',
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                _ProfileAction(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Mon abonnement',
                  onTap: () => context.push(AppRoutes.settings),
                ),
                _ProfileAction(
                  icon: Icons.tune_rounded,
                  label: 'Mes préférences',
                  onTap: () => context.push(AppRoutes.preferencesSettings),
                ),
                _ProfileAction(
                  icon: Icons.route_outlined,
                  label: 'Mes objectifs d’apprentissage',
                  onTap: () => context.push(AppRoutes.studyPlan),
                ),
                _ProfileAction(
                  icon: Icons.security_rounded,
                  label: 'Sécurité',
                  onTap: () => context.push(AppRoutes.profileSecurity),
                ),
                _ProfileAction(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => context.push(AppRoutes.notifications),
                ),
                _ProfileAction(
                  icon: Icons.palette_outlined,
                  label: 'Apparence',
                  onTap: () => context.push(AppRoutes.appearanceSettings),
                ),
                _ProfileAction(
                  icon: Icons.help_outline_rounded,
                  label: 'Aide',
                  onTap: () => context.push(AppRoutes.help),
                ),
                _ProfileAction(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Confidentialité',
                  onTap: () => context.push(AppRoutes.privacy),
                ),
                const SizedBox(height: AppSpacing.medium),
                OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context, ref),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Se déconnecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(authStateProvider.notifier).signOut();
      if (context.mounted) context.go(AppRoutes.welcome);
    }
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
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
          Expanded(child: Text(label)),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}
