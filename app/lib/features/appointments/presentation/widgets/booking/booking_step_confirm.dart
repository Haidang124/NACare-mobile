import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../providers/booking_controller.dart';

/// Step 5: confirm the booking details.
class BookingStepConfirm extends ConsumerWidget {
  const BookingStepConfirm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingControllerProvider).draft;
    return Column(
      children: [
        AppCard(
          child: Column(
            children: [
              InfoRow(label: 'Bệnh nhân', value: draft.profileName ?? '-'),
              InfoRow(
                  label: 'Chuyên khoa', value: draft.specialty?.name ?? '-'),
              InfoRow(
                  label: 'Bác sĩ',
                  value: draft.doctor?.name ?? 'Bệnh viện sắp xếp'),
              InfoRow(
                label: 'Thời gian',
                value: draft.date != null && draft.time != null
                    ? '${draft.date!.dayOfWeek}, ${draft.date!.dayNumber} · ${draft.time!.label}'
                    : '-',
                valueColor: AppColors.primaryDark,
              ),
              const InfoRow(label: 'Địa điểm', value: 'BV Hữu Nghị ĐK Nghệ An'),
              const Divider(height: 24),
              const InfoRow(label: 'Phí khám dự kiến', value: '150.000đ'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.warningTintSoft,
            border: Border.all(color: AppColors.warningBorder),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Text(
            'Vui lòng đến trước giờ hẹn 15 phút và mang theo CCCD, thẻ BHYT.',
            style: AppTypography.caption.copyWith(
                fontSize: 14, color: AppColors.warningText, height: 1.5),
          ),
        ),
      ],
    );
  }
}
