import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/exam_result.dart';
import '../providers/results_providers.dart';

class ResultDetailScreen extends ConsumerWidget {
  const ResultDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(examResultDetailProvider(id));

    return Scaffold(
      body: Column(
        children: [
          detailAsync.when(
            loading: () =>
                AppTopBar(title: 'Đang tải…', onBack: () => context.pop()),
            error: (_, __) => AppTopBar(
                title: 'Chi tiết kết quả', onBack: () => context.pop()),
            data: (d) => AppTopBar(
                title: d.title,
                subtitle: '${d.date} · ${d.doctor}',
                onBack: () => context.pop()),
          ),
          Expanded(
            child: AsyncValueView<ExamResultDetail>(
              value: detailAsync,
              onRetry: () => ref.invalidate(examResultDetailProvider(id)),
              data: (context, detail) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CHẨN ĐOÁN', style: AppTypography.eyebrow),
                          const SizedBox(height: 6),
                          Text(detail.diagnosis,
                              style: AppTypography.bodyBold
                                  .copyWith(fontSize: 16.5)),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.caption.copyWith(
                                  fontSize: 14.5,
                                  height: 1.55,
                                  color: AppColors.textSecondary),
                              children: [
                                const TextSpan(
                                    text: 'Lời dặn: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textBody)),
                                TextSpan(text: detail.advice),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Kết quả xét nghiệm',
                        style: AppTypography.bodyBold.copyWith(fontSize: 16)),
                    const SizedBox(height: 10),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: List.generate(detail.labs.length, (i) {
                          final lab = detail.labs[i];
                          final isLast = i == detail.labs.length - 1;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              color: lab.outOfRange
                                  ? AppColors.errorTintRow
                                  : Colors.white,
                              border: isLast
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                          color: AppColors.borderDivider)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(lab.name,
                                          style: AppTypography.bodyBold
                                              .copyWith(fontSize: 15)),
                                      Text('Tham chiếu: ${lab.reference}',
                                          style: AppTypography.caption.copyWith(
                                              fontSize: 12.5,
                                              color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: lab.outOfRange
                                                ? AppColors.error
                                                : AppColors.textPrimary),
                                        children: [
                                          TextSpan(text: lab.value),
                                          TextSpan(
                                              text: ' ${lab.unit}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                    if (lab.outOfRange)
                                      const Text('▲ NGOÀI NGƯỠNG',
                                          style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.error)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColors.accentTint,
                                borderRadius: BorderRadius.circular(11)),
                            child: const Icon(Icons.attach_file,
                                size: 18, color: AppColors.accentText),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(detail.attachmentName,
                                    style: AppTypography.bodyBold
                                        .copyWith(fontSize: 15)),
                                Text('${detail.attachmentSize} · Nhấn để xem',
                                    style: AppTypography.caption.copyWith(
                                        fontSize: 13,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          const Text('Tải ↓',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ],
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
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Xem đơn thuốc',
                    height: 52,
                    onPressed: () =>
                        context.push(AppRoutes.prescriptionPath(id)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Đặt tái khám',
                    height: 52,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.push(AppRoutes.bookAppointment),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
