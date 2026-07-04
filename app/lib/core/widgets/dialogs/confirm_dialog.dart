import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/app_button.dart';

/// Shared confirmation dialog — e.g. "discard the info you entered?" when leaving
/// mid-way through a multi-step flow (ui-ux-app-benh-nhan.md section 3, navigation rules).
class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xác nhận',
    String cancelLabel = 'Hủy',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Text(title, style: AppTypography.titleSmall),
        content: Text(message, style: AppTypography.body),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Expanded(
            child: AppButton(
              label: cancelLabel,
              variant: AppButtonVariant.secondary,
              height: 46,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(
              label: confirmLabel,
              variant: destructive
                  ? AppButtonVariant.destructive
                  : AppButtonVariant.primary,
              height: 46,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
