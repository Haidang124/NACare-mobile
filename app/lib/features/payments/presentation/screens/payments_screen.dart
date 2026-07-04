import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/payment.dart';
import '../providers/payments_providers.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingBillsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppTopBar(title: 'Thanh toán', onBack: () => context.pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AsyncValueView<List<PendingBill>>(
              value: pendingAsync,
              isEmpty: (data) => data.isEmpty,
              onRetry: () => ref.invalidate(pendingBillsProvider),
              emptyBuilder: (_) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.greenTintSoft,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                child: Text('Bạn không có khoản nào cần thanh toán.',
                    style: AppTypography.bodyBold.copyWith(
                        fontSize: 14.5, color: AppColors.primaryDark)),
              ),
              loadingBuilder: (_) => const SkeletonListTile(),
              data: (context, bills) => Column(
                children:
                    bills.map((bill) => _PendingBillCard(bill: bill)).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Text('Lịch sử giao dịch',
                style: AppTypography.bodyBold.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            AsyncValueView<List<PaymentTransaction>>(
              value: transactionsAsync,
              isEmpty: (data) => data.isEmpty,
              onRetry: () => ref.invalidate(transactionsProvider),
              emptyBuilder: (_) => const EmptyStateView(
                  icon: Icons.receipt_long_outlined,
                  title: 'Chưa có giao dịch nào'),
              data: (context, items) => AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: List.generate(items.length, (i) {
                    final t = items[i];
                    final isLast = i == items.length - 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                bottom:
                                    BorderSide(color: AppColors.borderDivider)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColors.greenTint,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(t.icon,
                                style: const TextStyle(fontSize: 17)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.title,
                                    style: AppTypography.bodyBold
                                        .copyWith(fontSize: 15)),
                                Text('${t.dateLabel} · ${t.method}',
                                    style: AppTypography.caption.copyWith(
                                        fontSize: 13,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(formatVnd(t.amountVnd),
                                  style: AppTypography.bodyBold
                                      .copyWith(fontSize: 15.5)),
                              Text(t.statusLabel,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingBillCard extends StatelessWidget {
  const _PendingBillCard({required this.bill});
  final PendingBill bill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningTintSoft,
        border: Border.all(color: AppColors.warningBorder),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('CẦN THANH TOÁN',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warning)),
              Spacer(),
              StatusBadge(
                  label: '1 khoản', tone: StatusTone.accent, dense: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(bill.title,
              style: AppTypography.bodyBold.copyWith(fontSize: 16)),
          const SizedBox(height: 2),
          Text('Hóa đơn ${bill.invoiceCode} · ${bill.dateLabel}',
              style: AppTypography.caption.copyWith(fontSize: 13.5)),
          const SizedBox(height: 10),
          Text(formatVnd(bill.amountVnd),
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warning)),
          const SizedBox(height: 12),
          AppButton(
            label: 'Thanh toán ngay',
            height: 46,
            onPressed: () => context.push(AppRoutes.billDetailPath(bill.id)),
          ),
        ],
      ),
    );
  }
}
