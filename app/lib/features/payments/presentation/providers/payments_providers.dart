import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../data/models/payment.dart';
import '../../data/repositories/mock_payments_repository.dart';
import '../../data/repositories/payments_repository.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return MockPaymentsRepository(ref.watch(mockConfigProvider));
});

final pendingBillsProvider =
    FutureProvider.autoDispose<List<PendingBill>>((ref) async {
  return (await ref.watch(paymentsRepositoryProvider).getPendingBills())
      .dataOrThrow;
});

final transactionsProvider =
    FutureProvider.autoDispose<List<PaymentTransaction>>((ref) async {
  return (await ref.watch(paymentsRepositoryProvider).getTransactions())
      .dataOrThrow;
});

final billDetailProvider =
    FutureProvider.autoDispose.family<BillDetail, String>((ref, id) async {
  return (await ref.watch(paymentsRepositoryProvider).getBillDetail(id))
      .dataOrThrow;
});
