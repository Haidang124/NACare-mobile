import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../../treatments/data/models/treatment.dart';
import '../../../treatments/presentation/providers/treatments_providers.dart';

/// Tab "Kết quả khám" = danh sách **lần điều trị** thật của hồ sơ (đọc HIS qua BE), lọc
/// theo năm. Chạm một lần điều trị mở danh sách phiếu EMR → xem PDF. Thay cho luồng
/// ExamResult cũ vốn gọi `/patient/results` (không có trên BE) — xem memory mobile-api-integration.
class ResultsTabScreen extends ConsumerWidget {
  const ResultsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatmentsAsync = ref.watch(treatmentsProvider);
    final selectedYear = ref.watch(treatmentsYearProvider);
    final profile = ref.watch(activeProfileProvider);

    final now = DateTime.now().year;
    final years = [now, now - 1, now - 2];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kết quả khám', style: AppTypography.tabTitle),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final y in years) ...[
                    AppChip(
                      label: '$y',
                      selected: y == selectedYear,
                      onTap: () =>
                          ref.read(treatmentsYearProvider.notifier).state = y,
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AsyncValueView<List<Treatment>>(
                  value: treatmentsAsync,
                  isEmpty: (data) => data.isEmpty,
                  onRetry: () => ref.invalidate(treatmentsProvider),
                  emptyBuilder: (_) => EmptyStateView(
                    icon: Icons.description_outlined,
                    title: 'Chưa có kết quả khám',
                    message: profile == null
                        ? 'Liên kết hồ sơ bệnh nhân để xem lịch sử khám và kết quả.'
                        : 'Năm $selectedYear chưa có lần khám nào tại bệnh viện.',
                  ),
                  data: (context, items) => ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _TreatmentCard(
                      item: items[i],
                      onTap: () => context.push(
                        AppRoutes.treatmentDocumentsPath(items[i].treatmentCode),
                        extra: items[i].title,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.item, this.onTap});
  final Treatment item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.date,
                  style: AppTypography.label.copyWith(fontSize: 13)),
              const Spacer(),
              if (item.typeName.isNotEmpty)
                StatusBadge(
                    label: item.typeName.toUpperCase(),
                    tone: StatusTone.neutral,
                    dense: true),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.title,
              style: AppTypography.bodyBold.copyWith(fontSize: 16.5)),
          if (item.icdCode.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text('Mã ICD: ${item.icdCode}',
                style: AppTypography.caption.copyWith(fontSize: 13.5)),
          ],
          if (item.department.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_hospital_outlined,
                    size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(item.department,
                      style: AppTypography.caption.copyWith(fontSize: 14)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
