import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Status badge (appointment/payment/result) — always pairs text with color, never
/// relying on color alone (the accessibility requirement in ui-ux-app-benh-nhan.md section 1).
enum StatusTone { success, warning, error, neutral, accent }

class StatusBadge extends StatelessWidget {
  const StatusBadge(
      {super.key,
      required this.label,
      this.tone = StatusTone.neutral,
      this.dense = false});

  final String label;
  final StatusTone tone;
  final bool dense;

  (Color, Color) get _colors => switch (tone) {
        StatusTone.success => (AppColors.primaryDark, AppColors.greenTint),
        StatusTone.warning => (AppColors.warning, AppColors.warningTint),
        StatusTone.error => (AppColors.error, AppColors.errorTint),
        StatusTone.neutral => (AppColors.textSecondary, AppColors.neutralTint),
        StatusTone.accent => (Colors.white, AppColors.accent),
      };

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _colors;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 8 : 10, vertical: dense ? 3 : 4.5),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm - 2)),
      child: Text(
        label,
        style: TextStyle(
            color: fg,
            fontSize: dense ? 11.5 : 12,
            fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Small dot indicating "unread" / "new" — shown next to a notification, a new result...
class UnreadDot extends StatelessWidget {
  const UnreadDot({super.key, this.size = 9});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
    );
  }
}
