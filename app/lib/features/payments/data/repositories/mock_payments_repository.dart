import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/payment.dart';
import 'payments_repository.dart';

class MockPaymentsRepository implements PaymentsRepository {
  MockPaymentsRepository(this._config);

  final MockConfig _config;

  static const _pending = [
    PendingBill(
      id: 'b1',
      title: 'Viện phí khám Tim mạch',
      invoiceCode: 'HĐ-260703-089',
      dateLabel: 'Hôm nay',
      amountVnd: 150000,
    ),
  ];

  // Matches the mockup.
  static const _transactions = [
    PaymentTransaction(
        icon: '🩺',
        title: 'Khám Nội tổng quát',
        dateLabel: '28/06/2026',
        method: 'VNPay',
        amountVnd: 120000,
        statusLabel: 'Thành công'),
    PaymentTransaction(
        icon: '🧪',
        title: 'Xét nghiệm máu',
        dateLabel: '28/06/2026',
        method: 'VNPay',
        amountVnd: 350000,
        statusLabel: 'Thành công'),
    PaymentTransaction(
        icon: '🫀',
        title: 'Khám Tim mạch',
        dateLabel: '15/03/2026',
        method: 'Momo',
        amountVnd: 150000,
        statusLabel: 'Thành công'),
    PaymentTransaction(
        icon: '💊',
        title: 'Tiền thuốc',
        dateLabel: '15/03/2026',
        method: 'Tiền mặt',
        amountVnd: 210000,
        statusLabel: 'Thành công'),
  ];

  @override
  Future<Result<List<PendingBill>>> getPendingBills() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success([]);
    return const Result.success(_pending);
  }

  @override
  Future<Result<List<PaymentTransaction>>> getTransactions() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(_transactions);
  }

  @override
  Future<Result<BillDetail>> getBillDetail(String id) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    // Matches the mockup: consult 150k + ECG 80k + cardiac ultrasound 240k = 470k, insurance pays 320k, 150k due.
    return const Result.success(
      BillDetail(
        items: [
          BillLineItem(name: 'Công khám Tim mạch', priceVnd: 150000),
          BillLineItem(name: 'Điện tâm đồ (ECG)', priceVnd: 80000),
          BillLineItem(name: 'Siêu âm tim', priceVnd: 240000),
        ],
        insuranceCoveredVnd: 320000,
        patientPaysVnd: 150000,
        methods: [
          PaymentMethod(id: 'vnpay', name: 'VNPay / QR ngân hàng', icon: '🏦'),
          PaymentMethod(id: 'momo', name: 'Ví MoMo', icon: '📱'),
          PaymentMethod(id: 'atm', name: 'Thẻ ATM / Visa', icon: '💳'),
        ],
      ),
    );
  }

  @override
  Future<Result<void>> confirmPayment(
      {required String id, required String methodId}) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(null);
  }
}
