import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/prescription.dart';
import '../providers/prescriptions_providers.dart';

class PrescriptionScreen extends ConsumerWidget {
  const PrescriptionScreen({super.key, required this.resultId});
  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionAsync = ref.watch(prescriptionProvider(resultId));

    return Scaffold(
      body: Column(
        children: [
          prescriptionAsync.when(
            loading: () =>
                AppTopBar(title: 'Đơn thuốc', onBack: () => context.pop()),
            error: (_, __) =>
                AppTopBar(title: 'Đơn thuốc', onBack: () => context.pop()),
            data: (p) => AppTopBar(
              title: 'Đơn thuốc',
              subtitle: 'Khám ${p.examDate} · ${p.durationDays} ngày',
              onBack: () => context.pop(),
            ),
          ),
          Expanded(
            child: AsyncValueView<Prescription>(
              value: prescriptionAsync,
              onRetry: () => ref.invalidate(prescriptionProvider(resultId)),
              data: (context, prescription) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                itemCount: prescription.medications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _MedicationCard(medication: prescription.medications[i]),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderCard))),
            child: AppButton(
              label: '🔔 Bật nhắc uống thuốc từ đơn này',
              onPressed: () => context.push(AppRoutes.medicationReminders),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({required this.medication});
  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppColors.greenTint,
                    borderRadius: BorderRadius.circular(13)),
                child: const Text('💊', style: TextStyle(fontSize: 19)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medication.name,
                        style: AppTypography.bodyBold.copyWith(fontSize: 16)),
                    Text(medication.strength,
                        style: AppTypography.caption.copyWith(fontSize: 13.5)),
                  ],
                ),
              ),
              StatusBadge(label: medication.days, tone: StatusTone.success),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: medication.times
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceBg,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('⏰ $t',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBody)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Text(medication.note,
              style: AppTypography.caption.copyWith(fontSize: 13.5)),
        ],
      ),
    );
  }
}
