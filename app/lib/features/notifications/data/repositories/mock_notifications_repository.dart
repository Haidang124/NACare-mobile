import 'package:flutter/material.dart';

import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/notification_item.dart';
import 'notifications_repository.dart';

class MockNotificationsRepository implements NotificationsRepository {
  MockNotificationsRepository(this._config);

  final MockConfig _config;

  static final List<NotificationItem> _all = [
    const NotificationItem(
      id: 'n1',
      type: NotificationType.result,
      emoji: '📄',
      iconBackground: Color(0xFFE3F5EA),
      title: 'Bạn có kết quả khám mới',
      body: 'Kết quả lần khám 28/06 đã sẵn sàng. Nhấn để xem chi tiết.',
      time: '2 giờ trước',
      unread: true,
    ),
    const NotificationItem(
      id: 'n2',
      type: NotificationType.appointment,
      emoji: '🗓',
      iconBackground: Color(0xFFFFF3DF),
      title: 'Nhắc lịch khám ngày mai',
      body: 'Khám Tim mạch lúc 09:30, Phòng 305. Nhớ mang CCCD và thẻ BHYT.',
      time: 'Hôm qua, 20:00',
      unread: true,
    ),
    const NotificationItem(
      id: 'n3',
      type: NotificationType.medication,
      emoji: '💊',
      iconBackground: Color(0xFFFDEBF4),
      title: 'Đến giờ uống thuốc',
      body: 'Amlodipin 5mg — 1 viên sau ăn sáng.',
      time: 'Hôm qua, 08:00',
      unread: false,
    ),
    const NotificationItem(
      id: 'n4',
      type: NotificationType.appointment,
      emoji: '✅',
      iconBackground: Color(0xFFE3F5EA),
      title: 'Đặt lịch thành công',
      body: 'Lịch hẹn LH-260712-031 đã được xác nhận.',
      time: '30/06, 15:22',
      unread: false,
    ),
  ];

  @override
  Future<Result<List<NotificationItem>>> getNotifications(
      {NotificationType? filter}) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success([]);
    final items =
        filter == null ? _all : _all.where((n) => n.type == filter).toList();
    return Result.success(items);
  }
}
