import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../providers/booking_controller.dart';
import 'booking_shared.dart';

/// Step 4: visit reason / symptoms (optional).
class BookingStepReason extends ConsumerWidget {
  const BookingStepReason({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (controller.text.isEmpty &&
        ref.read(bookingControllerProvider).draft.reason.isNotEmpty) {
      controller.text = ref.read(bookingControllerProvider).draft.reason;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lý do khám / triệu chứng',
            style: AppTypography.bodyBold.copyWith(fontSize: 16)),
        const SizedBox(height: 6),
        Text(
          'Không bắt buộc, nhưng giúp bác sĩ chuẩn bị tốt hơn.',
          style: AppTypography.caption.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
          style: AppTypography.body.copyWith(fontSize: 16),
          decoration: const InputDecoration(
              hintText: 'Mô tả ngắn gọn triệu chứng của bạn…'),
          onChanged: (v) =>
              ref.read(bookingControllerProvider.notifier).setReason(v),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kBookingReasonChips.map((r) {
            return AppChip(
              label: r,
              selected: false,
              onTap: () {
                controller.text = r;
                ref.read(bookingControllerProvider.notifier).setReason(r);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
