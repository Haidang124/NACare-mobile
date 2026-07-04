import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/prescription.dart';
import '../providers/prescriptions_providers.dart';

class MedicationRemindersScreen extends ConsumerWidget {
  const MedicationRemindersScreen({super.key});

  Future<void> _toggleDose(WidgetRef ref, int index, bool taken) async {
    await ref.read(prescriptionsRepositoryProvider).markDoseTaken(index, taken);
    ref.invalidate(todayDosesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dosesAsync = ref.watch(todayDosesProvider);

    return Scaffold(
      appBar: AppTopBar(title: 'Nhắc uống thuốc', onBack: () => context.pop()),
      body: AsyncValueView<List<MedicationDose>>(
        value: dosesAsync,
        onRetry: () => ref.invalidate(todayDosesProvider),
        data: (context, doses) {
          final takenCount = doses.where((d) => d.taken).length;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                      color: AppColors.greenTint,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  child: Text(
                    'Hôm nay bạn đã uống $takenCount/${doses.length} liều. Cố lên! 💪',
                    style: AppTypography.bodyBold
                        .copyWith(fontSize: 14.5, color: AppColors.primaryDark),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Lịch nhắc hôm nay',
                    style: AppTypography.bodyBold.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                ...List.generate(doses.length, (i) {
                  final dose = doses[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 52,
                            child: Text(dose.time,
                                style: AppTypography.titleSmall
                                    .copyWith(fontSize: 17)),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dose.name,
                                    style: AppTypography.bodyBold
                                        .copyWith(fontSize: 15)),
                                Text(dose.note,
                                    style: AppTypography.caption
                                        .copyWith(fontSize: 13.5)),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _toggleDose(ref, i, !dose.taken),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 38),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              backgroundColor: dose.taken
                                  ? AppColors.greenTint
                                  : Colors.white,
                              foregroundColor: dose.taken
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                              side: BorderSide(
                                  color: dose.taken
                                      ? AppColors.primary
                                      : AppColors.borderMedium,
                                  width: 1.5),
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            child: Text(dose.taken ? 'Đã uống' : 'Đánh dấu'),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                AppCard(
                  onTap: () => context.push(AppRoutes.bookAppointment),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColors.warningTint,
                            borderRadius: BorderRadius.circular(13)),
                        child: const Icon(Icons.calendar_month_outlined,
                            size: 19, color: AppColors.warning),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tái khám sau 4 tuần',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            Text('Dự kiến: 26/07/2026 · Nội tổng quát',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      const Text('Đặt lịch ›',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
