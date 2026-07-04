import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/exam_result.dart';
import '../providers/results_providers.dart';

class ResultsTabScreen extends ConsumerWidget {
  const ResultsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(examResultsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kết quả khám', style: AppTypography.tabTitle),
              const SizedBox(height: 16),
              Expanded(
                child: AsyncValueView<List<ExamResultSummary>>(
                  value: resultsAsync,
                  isEmpty: (data) => data.isEmpty,
                  onRetry: () => ref.invalidate(examResultsProvider),
                  emptyBuilder: (_) => const EmptyStateView(
                    icon: Icons.description_outlined,
                    title: 'Chưa có kết quả khám',
                    message:
                        'Kết quả sẽ xuất hiện ở đây sau khi bạn hoàn tất buổi khám.',
                  ),
                  data: (context, items) => ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ResultCard(item: items[i]),
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.item});
  final ExamResultSummary item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.resultDetailPath(item.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.date,
                  style: AppTypography.label.copyWith(fontSize: 13)),
              const Spacer(),
              if (item.isNew)
                const StatusBadge(
                    label: 'MỚI', tone: StatusTone.accent, dense: true),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.title,
              style: AppTypography.bodyBold.copyWith(fontSize: 16.5)),
          const SizedBox(height: 3),
          Text(item.doctor,
              style: AppTypography.caption.copyWith(fontSize: 14.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: item.tags
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.greenTint,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(t,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
