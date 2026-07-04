import 'package:flutter/material.dart';

enum NotificationType { appointment, result, medication }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.emoji,
    required this.iconBackground,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });

  final String id;
  final NotificationType type;

  /// Emoji-style icon to match the mockup (📄🗓💊✅).
  final String emoji;
  final Color iconBackground;
  final String title;
  final String body;
  final String time;
  final bool unread;
}
