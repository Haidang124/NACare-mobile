import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/app_button.dart';

/// Three shared state blocks: empty / error / permission — each is an icon + one
/// sentence + one button (following the "few words, one clear action" principle in
/// ui-ux-app-benh-nhan.md section 1, and the 5-state checklist in section 7).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: icon,
      iconBackground: AppColors.iconBgSoft,
      iconColor: AppColors.textTertiary,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    this.title = 'Có lỗi xảy ra',
    this.message,
    this.actionLabel = 'Thử lại',
    this.onRetry,
  });

  final String title;
  final String? message;
  final String actionLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: Icons.wifi_off_rounded,
      iconBackground: AppColors.errorTint,
      iconColor: AppColors.error,
      title: title,
      message: message,
      actionLabel: onRetry != null ? actionLabel : null,
      onAction: onRetry,
    );
  }
}

class PermissionStateView extends StatelessWidget {
  const PermissionStateView({
    super.key,
    this.title = 'Cần đăng nhập',
    this.message = 'Vui lòng đăng nhập để xem nội dung này.',
    this.actionLabel = 'Đăng nhập',
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: Icons.lock_outline_rounded,
      iconBackground: AppColors.greenTint,
      iconColor: AppColors.primaryDark,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class _StateScaffold extends StatelessWidget {
  const _StateScaffold({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: iconBackground, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title,
                style: AppTypography.titleSmall, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  expanded: false,
                  height: 46),
            ],
          ],
        ),
      ),
    );
  }
}
