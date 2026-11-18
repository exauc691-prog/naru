import '../models/enums/notification_type.dart';
import '../models/notification_model.dart';
import 'mock_dates.dart';

final mockNotifications = List<NotificationModel>.unmodifiable([
  NotificationModel(
    id: 'notification-daily-goal',
    title: 'Ton objectif du jour est atteint',
    message: 'Tu as consacré 25 minutes à ton apprentissage aujourd’hui.',
    type: NotificationType.goal,
    createdAt: mockDate(hour: 11, minute: 20),
    isRead: false,
  ),
  NotificationModel(
    id: 'notification-streak',
    title: 'Ta série continue',
    message:
        'Quatre jours de pratique régulière : garde ce rythme qui te convient.',
    type: NotificationType.reminder,
    createdAt: mockDate(hour: 9, minute: 0),
    isRead: false,
  ),
  NotificationModel(
    id: 'notification-first-course',
    title: 'Un cours terminé',
    message: 'Bravo, tu as terminé « Penser comme un algorithme ».',
    type: NotificationType.achievement,
    createdAt: mockDate(daysAgo: 6, hour: 16),
    isRead: true,
  ),
  NotificationModel(
    id: 'notification-dart-course',
    title: 'La suite de Dart est prête',
    message: 'Les prochaines leçons portent sur les conditions et les boucles.',
    type: NotificationType.courseUpdate,
    createdAt: mockDate(daysAgo: 1, hour: 10),
    isRead: true,
  ),
  NotificationModel(
    id: 'notification-welcome',
    title: 'Bienvenue dans Naru',
    message: 'Choisis un petit créneau régulier et avance à ton rythme.',
    type: NotificationType.general,
    createdAt: mockDate(daysAgo: 12, hour: 9),
    isRead: true,
  ),
]);
