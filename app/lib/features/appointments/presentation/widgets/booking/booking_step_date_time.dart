import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../providers/appointments_providers.dart';
import '../../providers/booking_controller.dart';
import 'booking_shared.dart';

/// Step 3: choose a doctor (optional) + date + time slot.
class BookingStepDateTime extends ConsumerWidget {
  const BookingStepDateTime({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingControllerProvider).draft;
    final doctorsAsync = ref.watch(doctorsProvider(draft.specialty?.id ?? ''));
    final datesAsync = ref.watch(bookingDatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bác sĩ (không bắt buộc)',
            style: AppTypography.bodyBold.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        AsyncValueView(
          value: doctorsAsync,
          onRetry: () =>
              ref.invalidate(doctorsProvider(draft.specialty?.id ?? '')),
          data: (context, doctors) => Column(
            children: doctors.map((d) {
              final selected = draft.doctor?.id == d.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BookingSelectableTile(
                  dense: true,
                  selected: selected,
                  onTap: () => ref
                      .read(bookingControllerProvider.notifier)
                      .selectDoctor(d),
                  leading: CircleAvatar(
                    radius: 19,
                    backgroundColor: AppColors.greenTint,
                    child: Icon(
                      d.isAnyDoctor
                          ? Icons.local_hospital_outlined
                          : Icons.medical_services_outlined,
                      size: 17,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  title: d.name,
                  subtitle: d.subtitle,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
        Text('Chọn ngày', style: AppTypography.bodyBold.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: AsyncValueView(
            value: datesAsync,
            onRetry: () => ref.invalidate(bookingDatesProvider),
            data: (context, dates) => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final d = dates[i];
                final selected = draft.date?.dayNumber == d.dayNumber &&
                    draft.date?.dayOfWeek == d.dayOfWeek;
                return GestureDetector(
                  onTap: d.isOff
                      ? null
                      : () => ref
                          .read(bookingControllerProvider.notifier)
                          .selectDate(d),
                  child: Opacity(
                    opacity: d.isOff ? 0.4 : 1,
                    child: Container(
                      width: 58,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.borderSoft,
                            width: 2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(d.dayOfWeek,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white70
                                      : AppColors.textSecondary)),
                          Text(d.dayNumber,
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Chọn khung giờ',
            style: AppTypography.bodyBold.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        if (draft.date == null)
          Text('Chọn ngày trước để xem khung giờ trống.',
              style: AppTypography.caption.copyWith(fontSize: 14))
        else
          Consumer(
            builder: (context, ref, _) {
              final timesAsync = ref.watch(bookingTimesProvider(draft.date!));
              return AsyncValueView(
                value: timesAsync,
                onRetry: () =>
                    ref.invalidate(bookingTimesProvider(draft.date!)),
                data: (context, times) => GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: times.map((t) {
                    final selected = draft.time?.label == t.label;
                    return GestureDetector(
                      onTap: t.isOff
                          ? null
                          : () => ref
                              .read(bookingControllerProvider.notifier)
                              .selectTime(t),
                      child: Opacity(
                        opacity: t.isOff ? 0.35 : 1,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.white,
                            border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.borderSoft,
                                width: 2),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            t.label,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              decoration:
                                  t.isOff ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
      ],
    );
  }
}
