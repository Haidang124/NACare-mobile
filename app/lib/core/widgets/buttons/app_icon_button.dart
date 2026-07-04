import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Rounded 38x38 square icon button for back/close/secondary actions on the app bar
/// and screen headers. Centralized here instead of copying `_RoundIcon` across files.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.background = AppColors.iconBgSoft,
    this.iconColor = AppColors.textPrimary,
    this.size = 38,
    this.iconSize = 17,
  });

  /// On-dark variant (e.g. the QR check-in screen with a dark-green background).
  const AppIconButton.onDark({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 38,
    this.iconSize = 16,
  })  : background = const Color(0x26FFFFFF),
        iconColor = Colors.white;

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color iconColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}
