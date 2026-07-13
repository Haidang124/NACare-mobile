import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/app_icon_button.dart';

/// Title bar for detail screens (with a back button) — used instead of Material's AppBar
/// to match the mockup's padding/rounded frame rather than the system default.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.backgroundColor = AppColors.surfaceCard,
    this.showBorder = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Color backgroundColor;
  final bool showBorder;

  // Cần cao hơn khi có subtitle: title (18sp) + subtitle (13sp) + padding dọc vượt 64px
  // → tràn "BOTTOM OVERFLOWED". Chỉ-title thì 64px là đủ.
  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 78);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showBorder
            ? const Border(bottom: BorderSide(color: AppColors.borderCard))
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(AppSpacing.xl, 10, AppSpacing.xl, 14),
          child: Row(
            children: [
              if (onBack != null)
                AppIconButton(
                    icon: Icons.arrow_back_ios_new_rounded, onTap: onBack!)
              else
                const SizedBox.shrink(),
              if (onBack != null) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: AppTypography.titleSmall,
                        overflow: TextOverflow.ellipsis),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: AppTypography.caption.copyWith(
                              fontSize: 13, color: AppColors.textTertiary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
