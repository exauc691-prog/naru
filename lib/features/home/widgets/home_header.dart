import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.onNotifications,
    this.onProfile,
  });

  final VoidCallback onNotifications;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppColors.of(context);
    final profile = ref.watch(userProfileProvider);
    final user = profile.when(
      data: (value) => value,
      loading: () => null,
      error: (_, _) => null,
    );
    final fullName = user?.fullName.trim() ?? '';
    final firstName = fullName.isEmpty
        ? ''
        : fullName.split(RegExp(r'\s+')).first;
    final greeting = profile.when(
      data: (_) => firstName.isEmpty ? 'Bonjour' : 'Bonjour, $firstName',
      loading: () => 'Bonjour',
      error: (_, _) => 'Profil indisponible',
    );
    final subtitle = profile.when(
      data: (_) => 'Prêt à apprendre quelque chose de nouveau ?',
      loading: () => 'Chargement de votre profil…',
      error: (_, _) => 'Impossible de charger votre profil.',
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: palette.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotifications,
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 4),
        Semantics(
          button: true,
          label: user == null ? 'Profil utilisateur' : 'Profil de $fullName',
          child: InkWell(
            onTap: onProfile,
            borderRadius: BorderRadius.circular(20),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: palette.primaryContainer,
              foregroundColor: palette.onPrimaryContainer,
              child: Text(
                firstName.isEmpty
                    ? '?'
                    : firstName.substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
