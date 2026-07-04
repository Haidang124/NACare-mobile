import '../../../../core/network/result.dart';
import '../models/payment.dart';

abstract class PaymentsRepository {
  Future<Result<List<PendingBill>>> getPendingBills();
  Future<Result<List<PaymentTransaction>>> getTransactions();
  Future<Result<BillDetail>> getBillDetail(String id);
  Future<Result<void>> confirmPayment(
      {required String id, required String methodId});
}
