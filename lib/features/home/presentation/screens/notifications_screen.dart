import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../shared/models/enums/notification_type.dart';
import '../../../../shared/models/notification_model.dart';
import '../../providers/home_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(dashboardNotificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: notifications.value == null
                ? null
                : () => ref
                    .read(dashboardNotificationsProvider.notifier)
                    .markAllAsRead(),
            child: const Text('Tout lire'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: notifications.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Chargement des notifications',
                ),
              ),
              error: (_, _) => AppErrorView(
                message: 'Les notifications ne peuvent pas être chargées.',
                onRetry: () =>
                    ref.invalidate(dashboardNotificationsProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'Aucune notification',
                    description:
                        'Les nouveautés importantes apparaîtront ici.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.horizontalMargin),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = items[index];
                    return _NotificationTile(
                      notification: notification,
                      onTap: () => ref
                          .read(dashboardNotificationsProvider.notifier)
                          .markAsRead(notification.id),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? palette.surfaceMuted
            : palette.primaryContainer,
        foregroundColor: notification.isRead
            ? palette.textSecondary
            : palette.primary,
        child: Icon(_iconFor(notification.type)),
      ),
      title: Text(
        notification.title,
        style: notification.isRead
            ? Theme.of(context).textTheme.titleSmall
            : Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
      ),
      subtitle: Text(notification.message),
      trailing: notification.isRead
          ? null
          : const Icon(Icons.circle, size: 8),
    );
  }

  static IconData _iconFor(NotificationType type) => switch (type) {
    NotificationType.general => Icons.notifications_outlined,
    NotificationType.reminder => Icons.schedule_rounded,
    NotificationType.achievement => Icons.emoji_events_outlined,
    NotificationType.courseUpdate => Icons.school_outlined,
    NotificationType.goal => Icons.flag_outlined,
  };
}
