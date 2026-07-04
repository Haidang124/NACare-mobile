import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// A "label — value" row reused across appointment details, booking confirmation,
/// personal info, bill details...
class InfoRow extends StatelessWidget {
  const InfoRow(
      {super.key,
      required this.label,
      required this.value,
      this.valueColor = AppColors.textPrimary});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(fontSize: 15)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.bodyBold
                  .copyWith(fontSize: 15, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
