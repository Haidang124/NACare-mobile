import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Shared text field — small uppercase label above, rounded frame per the design system.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefixText,
    this.onChanged,
    this.enabled = true,
    this.helperText,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final String? prefixText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.bodySecondary),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          style: AppTypography.bodyBold.copyWith(fontSize: 17),
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            prefixStyle: AppTypography.bodyBold.copyWith(fontSize: 18),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Text(helperText!,
              style: AppTypography.caption
                  .copyWith(fontSize: 13, color: AppColors.textTertiary)),
        ],
      ],
    );
  }
}
