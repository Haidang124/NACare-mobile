import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Circular avatar showing initials — used for patient, family member, and doctor profiles.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.background = AppColors.primary,
    this.foreground = Colors.white,
    this.ringColor,
  });

  final String initials;
  final double size;
  final Color background;
  final Color foreground;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: ringColor != null
            ? Border.all(color: ringColor!, width: 2.5)
            : null,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
        ),
      ),
    );
    return avatar;
  }
}
