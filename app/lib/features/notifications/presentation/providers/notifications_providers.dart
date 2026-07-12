import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/config_providers.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/mock_config.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/api_notifications_repository.dart';
import '../../data/repositories/mock_notifications_repository.dart';
import '../../data/repositories/notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  if (ref.watch(useMockProvider)) {
    return MockNotificationsRepository(ref.watch(mockConfigProvider));
  }
  return ApiNotificationsRepository(ref.watch(dioProvider));
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
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  if (repo is ApiNotificationsRepository) {
    return (await repo.getUnreadCount()).dataOrThrow;
  }
  final items = (await repo.getNotifications()).dataOrThrow;
  return items.where((n) => n.unread).length;
});
