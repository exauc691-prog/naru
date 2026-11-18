import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sécurité')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              const AppCard(
                child: Text(
                  'Les fonctions suivantes seront connectées au backend sécurisé '
                  'ultérieurement.',
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              const _SecurityAction(
                icon: Icons.lock_outline_rounded,
                title: 'Modifier le mot de passe',
              ),
              const _SecurityAction(
                icon: Icons.mark_email_read_outlined,
                title: 'Vérification de l’e-mail',
              ),
              const _SecurityAction(
                icon: Icons.phone_android_rounded,
                title: 'Vérification du téléphone',
              ),
              const _SecurityAction(
                icon: Icons.devices_rounded,
                title: 'Sessions actives',
              ),
              const _SecurityAction(
                icon: Icons.logout_rounded,
                title: 'Déconnexion de toutes les sessions',
              ),
              const _SecurityAction(
                icon: Icons.verified_user_outlined,
                title: 'Authentification à deux facteurs',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SecurityAction extends StatelessWidget {
  const _SecurityAction({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.small),
    child: AppCard(
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
