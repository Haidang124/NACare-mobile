import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/health_metric.dart';
import '../providers/health_metrics_providers.dart';

class HealthMetricsScreen extends ConsumerWidget {
  const HealthMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(metricsProvider);
    final trendAsync = ref.watch(bloodPressureTrendProvider);

    return Scaffold(
      appBar: AppTopBar(title: 'Chỉ số sức khỏe', onBack: () => context.pop()),
      body: Column(
        children: [
          Expanded(
            child: AsyncValueView<List<MetricCard>>(
              value: metricsAsync,
              onRetry: () {
                ref.invalidate(metricsProvider);
                ref.invalidate(bloodPressureTrendProvider);
              },
              data: (context, metrics) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: metrics.map((m) {
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(m.icon,
                                      style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(m.label,
                                          style: AppTypography.caption.copyWith(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary),
                                  children: [
                                    TextSpan(text: m.value),
                                    TextSpan(
                                        text: ' ${m.unit}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.trend,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: m.trendPositive
                                        ? AppColors.primaryDark
                                        : AppColors.warning),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Huyết áp 7 ngày qua',
                        style: AppTypography.bodyBold.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    AppCard(
                      child: SizedBox(
                        height: 140,
                        child: AsyncValueView<List<BloodPressureSample>>(
                          value: trendAsync,
                          onRetry: () =>
                              ref.invalidate(bloodPressureTrendProvider),
                          data: (context, samples) => Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: samples.map((s) {
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FractionallySizedBox(
                                        heightFactor: s.heightFraction,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: s.isHigh
                                                ? AppColors.warning
                                                : AppColors.primary,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(6)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(s.day,
                                          style: AppTypography.caption.copyWith(
                                              fontSize: 11,
                                              color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
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
              label: '＋ Nhập chỉ số mới',
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
