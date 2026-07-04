import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, text, destructive }

/// Shared button for the whole app — includes loading/disabled states per the
/// design system required in ui-ux-app-benh-nhan.md section 2.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;
  final double? height;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: variant == AppButtonVariant.secondary
                  ? AppColors.primaryDark
                  : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final buttonHeight = height ?? AppSpacing.buttonHeight;
    final button = _buildByVariant(context, child, buttonHeight);

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildByVariant(BuildContext context, Widget child, double height) {
    // Non-expanded buttons hug their content. `Size.fromHeight` sets minWidth to
    // infinity, which is fine inside a bounded Column but crashes inside an unbounded
    // Row — so only force full width when [expanded] (the SizedBox already does that).
    final minSize = expanded ? Size.fromHeight(height) : Size(0, height);
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            minimumSize: minSize,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          ),
          child: child,
        );
      case AppButtonVariant.secondary:
        return OutlinedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(minimumSize: minSize),
          child: child,
        );
      case AppButtonVariant.destructive:
        return OutlinedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: minSize,
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.errorBorder, width: 1.5),
            textStyle: AppTypography.button.copyWith(color: AppColors.error),
          ),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: _isEnabled ? onPressed : null,
          style: TextButton.styleFrom(minimumSize: minSize),
          child: DefaultTextStyle.merge(
            style: AppTypography.bodySecondary.copyWith(
              color: _isEnabled ? AppColors.textSecondary : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            child: child,
          ),
        );
    }
  }
}
