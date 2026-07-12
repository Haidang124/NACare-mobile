import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Các tiện ích format dùng khi map dữ liệu data-shaped của BE (DateTime UTC, số...)
/// sang model UI-shaped của app. Gom một chỗ để mọi Api*Repository dùng nhất quán.

/// 'dd/MM/yyyy' theo giờ máy.
String vnDate(DateTime utc) => DateFormat('dd/MM/yyyy').format(utc.toLocal());

/// Nhãn thời điểm ngắn gọn cho lịch hẹn: "Hôm nay, 09:30" hoặc "12/07 · 08:00".
String vnWhenLabel(DateTime utc) {
  final dt = utc.toLocal();
  final now = DateTime.now();
  final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
  final time = DateFormat('HH:mm').format(dt);
  if (isToday) return 'Hôm nay, $time';
  return '${DateFormat('dd/MM').format(dt)} · $time';
}

/// Viết tắt tên (tối đa 2 chữ cái đầu) cho avatar.
String initialsFrom(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  return t
      .split(RegExp(r'\s+'))
      .map((w) => w[0])
      .take(2)
      .join()
      .toUpperCase();
}

const _avatarPalette = <Color>[
  Color(0xFF149A4B),
  Color(0xFFE5399B),
  Color(0xFFB36A00),
  Color(0xFF0F7C3C),
  Color(0xFF2563EB),
  Color(0xFF7C3AED),
];

/// Màu avatar ổn định theo một khoá (vd id hồ sơ) — cùng khoá luôn ra cùng màu.
Color avatarColorFor(String seed) =>
    _avatarPalette[seed.hashCode.abs() % _avatarPalette.length];
