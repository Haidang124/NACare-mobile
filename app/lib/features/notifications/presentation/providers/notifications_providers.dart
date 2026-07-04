import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/mock_notifications_repository.dart';
import '../../data/repositories/notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return MockNotificationsRepository(ref.watch(mockConfigProvider));
});

final notificationFilterProvider =
    StateProvider<NotificationType?>((ref) => null);

final notificationsProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  final filter = ref.watch(notificationFilterProvider);
  final repo = ref.watch(notificationsRepositoryProvider);
  return (await repo.getNotifications(filter: filter)).dataOrThrow;
});

/// Used by the notification bell badge on the Home screen.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationsProvider).valueOrNull ?? const [];
  return items.where((n) => n.unread).length;
});
