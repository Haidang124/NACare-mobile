import '../../../../core/network/result.dart';
import '../models/notification_item.dart';

abstract class NotificationsRepository {
  Future<Result<List<NotificationItem>>> getNotifications(
      {NotificationType? filter});
}
