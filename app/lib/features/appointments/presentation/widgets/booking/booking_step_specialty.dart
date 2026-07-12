import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/models/specialty.dart';
import '../../providers/appointments_providers.dart';
import '../../providers/booking_controller.dart';

/// Step 2: choose a specialty.
class BookingStepSpecialty extends ConsumerWidget {
  const BookingStepSpecialty({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final selected = ref.watch(bookingControllerProvider).draft.specialty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.borderSoft),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Text('Tìm chuyên khoa, dịch vụ…',
                  style: AppTypography.caption
                      .copyWith(fontSize: 15.5, color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AsyncValueView<List<Specialty>>(
          value: specialtiesAsync,
          onRetry: () => ref.invalidate(specialtiesProvider),
          data: (context, specialties) => GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 132,
            ),
            children: specialties.map((s) {
              final isSelected = selected?.id == s.id;
              return AppCard(
                borderColor:
                    isSelected ? AppColors.primary : AppColors.borderCard,
                onTap: () => ref
                    .read(bookingControllerProvider.notifier)
                    .selectSpecialty(s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.greenTint,
                          borderRadius: BorderRadius.circular(12)),
                      child:
                          Text(s.emoji, style: const TextStyle(fontSize: 19)),
                    ),
                    const SizedBox(height: 8),
                    Text(s.name,
                        style: AppTypography.bodyBold.copyWith(fontSize: 14.5)),
                    Text(s.note,
                        style: AppTypography.caption.copyWith(fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
