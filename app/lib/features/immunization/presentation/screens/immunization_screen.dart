import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/vaccine_record.dart';
import '../providers/immunization_providers.dart';

class ImmunizationScreen extends ConsumerWidget {
  const ImmunizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(immunizationRecordProvider);

    return Scaffold(
      appBar: AppTopBar(title: 'Sổ tiêm chủng', onBack: () => context.pop()),
      body: Column(
        children: [
          Expanded(
            child: AsyncValueView<ImmunizationRecord>(
              value: recordAsync,
              onRetry: () => ref.invalidate(immunizationRecordProvider),
              data: (context, record) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (record.upcoming != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.accentTint,
                          border: Border.all(color: AppColors.accentBorder),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Row(
                          children: [
                            const Text('💉', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Sắp đến lịch tiêm',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accentText)),
                                  Text(
                                    '${record.upcoming!.name} · dự kiến ${record.upcoming!.expectedDate}',
                                    style: const TextStyle(
                                        fontSize: 13.5,
                                        color: AppColors.accentTextSoft),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text('Lịch sử tiêm',
                        style: AppTypography.bodyBold.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    if (record.history.isEmpty)
                      const EmptyStateView(
                          icon: Icons.vaccines_outlined,
                          title: 'Chưa có lịch sử tiêm chủng')
                    else
                      AppCard(
                        child: Column(
                          children: List.generate(record.history.length, (i) {
                            final event = record.history[i];
                            final isLast = i == record.history.length - 1;
                            final done = event.state == VaccineEventState.done;
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: done
                                              ? AppColors.primary
                                              : Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: done
                                                  ? AppColors.primary
                                                  : AppColors.borderMedium,
                                              width: 2),
                                        ),
                                        child: done
                                            ? const Icon(Icons.check,
                                                size: 13, color: Colors.white)
                                            : null,
                                      ),
                                      if (!isLast)
                                        Expanded(
                                            child: Container(
                                                width: 2,
                                                color: AppColors.timelineLine)),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(event.name,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: done
                                                      ? AppColors.textPrimary
                                                      : AppColors
                                                          .textTertiary)),
                                          const SizedBox(height: 2),
                                          Text(event.info,
                                              style: AppTypography.caption
                                                  .copyWith(fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderCard))),
            child: AppButton(
              label: '＋ Thêm mũi tiêm',
              height: 52,
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sẽ hỗ trợ ở bản sau.')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
