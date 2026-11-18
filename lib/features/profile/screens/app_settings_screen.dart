import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
              children: [
                Text('Compte',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.small),
                _SettingTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Sécurité',
                  onTap: () => context.push(AppRoutes.profileSecurity),
                ),
                const SizedBox(height: AppSpacing.large),
                Text('Apparence',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.small),
                theme.when(
                  data: (mode) => AppCard(
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Système'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Clair'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Sombre'),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (values) => ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(values.first),
                    ),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) =>
                      const Text('Le thème ne peut pas être chargé.'),
                ),
                const SizedBox(height: AppSpacing.large),
                Text('Autres préférences',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.small),
                _SettingTile(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Abonnement',
                  onTap: () => context.push(AppRoutes.settings),
                ),
                _SettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () => context.push(AppRoutes.notifications),
                ),
                _SettingTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Confidentialité',
                  onTap: () => context.push(AppRoutes.privacy),
                ),
                _SettingTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Aide',
                  onTap: () => context.push(AppRoutes.help),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
          Expanded(child: Text(title)),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}
