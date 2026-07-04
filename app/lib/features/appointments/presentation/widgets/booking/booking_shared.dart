import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

/// Suggested visit reasons used in booking step 4.
const kBookingReasonChips = [
  'Đau đầu, chóng mặt',
  'Ho, sốt',
  'Khám định kỳ',
  'Tái khám theo hẹn'
];

/// Shared selectable tile (profile/doctor) across booking steps — green border when selected.
class BookingSelectableTile extends StatelessWidget {
  const BookingSelectableTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.dense = false,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(dense ? 13 : 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(dense ? 13 : 14),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: dense ? 13 : 14, vertical: dense ? 11 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(dense ? 13 : 14),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.borderSoft,
                width: 2),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.bodyBold
                            .copyWith(fontSize: dense ? 15 : 16)),
                    Text(subtitle,
                        style: AppTypography.caption
                            .copyWith(fontSize: dense ? 12.5 : 13.5)),
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

/// Circular radio button used in the profile-selection step.
class BookingRadio extends StatelessWidget {
  const BookingRadio({super.key, required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderMedium,
            width: 2),
      ),
      child: selected
          ? Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle))
          : null,
    );
  }
}
