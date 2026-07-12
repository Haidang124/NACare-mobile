import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../models/notification_item.dart';
import 'notifications_repository.dart';

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<NotificationItem>>> getNotifications({
    NotificationType? filter,
  }) =>
      apiCall(
        () => _dio.get(
          '/patient/notifications',
          queryParameters: {
            if (filter != null) 'type': _toServerType(filter),
          },
        ),
        (json) => (json as List)
            .map((e) => _map((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Future<Result<int>> getUnreadCount() => apiCall(
        () => _dio.get('/patient/notifications/unread-count'),
        (json) => (json as num).toInt(),
      );

  NotificationItem _map(Map<String, dynamic> json) {
    final type = _mapType(json['type']);
    final sentAt = DateTime.parse(json['sentAtUtc'] as String).toLocal();
    final visual = _visualFor(type);
    return NotificationItem(
      id: json['id'].toString(),
      type: type,
      emoji: visual.emoji,
      iconBackground: visual.background,
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      time: _relativeTime(sentAt),
      unread: (json['unread'] as bool?) ?? false,
    );
  }

  int _toServerType(NotificationType type) => switch (type) {
        NotificationType.appointment => 0,
        NotificationType.result => 1,
        NotificationType.medication => 2,
      };

  NotificationType _mapType(dynamic value) {
    if (value is int) {
      return switch (value) {
        1 => NotificationType.result,
        2 => NotificationType.medication,
        _ => NotificationType.appointment,
      };
    }
    return switch (value?.toString().toLowerCase()) {
      'result' => NotificationType.result,
      'medication' => NotificationType.medication,
      _ => NotificationType.appointment,
    };
  }

  ({String emoji, Color background}) _visualFor(NotificationType type) =>
      switch (type) {
        NotificationType.appointment => (
            emoji: '🗓',
            background: const Color(0xFFFFF3DF),
          ),
        NotificationType.result => (
            emoji: '📄',
            background: const Color(0xFFE3F5EA),
          ),
        NotificationType.medication => (
            emoji: '💊',
            background: const Color(0xFFFDEBF4),
          ),
      };

  String _relativeTime(DateTime sentAt) {
    final diff = DateTime.now().difference(sentAt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) {
      final time = DateFormat('HH:mm').format(sentAt);
      return 'Hôm qua, $time';
    }
    return DateFormat('dd/MM, HH:mm').format(sentAt);
  }
}
