import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/payment.dart';
import '../providers/payments_providers.dart';

final _selectedMethodProvider =
    StateProvider.autoDispose<String?>((ref) => null);

class BillDetailScreen extends ConsumerStatefulWidget {
  const BillDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends ConsumerState<BillDetailScreen> {
  bool _isSubmitting = false;

  Future<void> _confirm(BillDetail detail) async {
    final methodId =
        ref.read(_selectedMethodProvider) ?? detail.methods.first.id;
    setState(() => _isSubmitting = true);
    final result = await ref
        .read(paymentsRepositoryProvider)
        .confirmPayment(id: widget.id, methodId: methodId);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) {
        ref.invalidate(pendingBillsProvider);
        ref.invalidate(transactionsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thanh toán thành công')));
        context.pop();
      },
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(billDetailProvider(widget.id));
    final selectedMethod = ref.watch(_selectedMethodProvider);

    return Scaffold(
      appBar: AppTopBar(title: 'Chi tiết hóa đơn', onBack: () => context.pop()),
      body: AsyncValueView<BillDetail>(
        value: detailAsync,
        onRetry: () => ref.invalidate(billDetailProvider(widget.id)),
        data: (context, detail) {
          final activeMethod = selectedMethod ?? detail.methods.first.id;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        child: Column(
                          children: [
                            ...detail.items.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.name,
                                          style: AppTypography.caption
                                              .copyWith(fontSize: 15)),
                                      Text(formatVnd(item.priceVnd),
                                          style: AppTypography.bodyBold
                                              .copyWith(fontSize: 15)),
                                    ],
                                  ),
                                )),
                            const Divider(height: 20),
                            InfoRow(
                              label: 'BHYT chi trả',
                              value:
                                  '− ${formatVnd(detail.insuranceCoveredVnd)}',
                              valueColor: AppColors.primaryDark,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Bạn cần trả',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary)),
                                Text(formatVnd(detail.patientPaysVnd),
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.warning)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Phương thức thanh toán',
                          style: AppTypography.bodyBold.copyWith(fontSize: 16)),
                      const SizedBox(height: 12),
                      ...detail.methods.map((m) {
                        final selected = m.id == activeMethod;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () => ref
                                  .read(_selectedMethodProvider.notifier)
                                  .state = m.id,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.borderSoft,
                                      width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: AppColors.greenTint,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Text(m.icon,
                                          style: const TextStyle(fontSize: 19)),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                        child: Text(m.name,
                                            style: AppTypography.bodyBold
                                                .copyWith(fontSize: 15.5))),
                                    Container(
                                      width: 22,
                                      height: 22,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: selected
                                                ? AppColors.primary
                                                : AppColors.borderMedium,
                                            width: 2),
                                      ),
                                      child: selected
                                          ? Container(
                                              width: 11,
                                              height: 11,
                                              decoration: const BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle))
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(top: BorderSide(color: AppColors.borderCard))),
                child: AppButton(
                  label:
                      'Xác nhận thanh toán ${formatVnd(detail.patientPaysVnd)}',
                  isLoading: _isSubmitting,
                  onPressed: () => _confirm(detail),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
