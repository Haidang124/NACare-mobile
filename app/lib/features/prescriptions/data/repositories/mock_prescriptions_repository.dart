import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/prescription.dart';
import 'prescriptions_repository.dart';

class MockPrescriptionsRepository implements PrescriptionsRepository {
  MockPrescriptionsRepository(this._config);

  final MockConfig _config;

  // Data matches the mockup: Amlodipine, Metformin, Vitamin D3 (30 days).
  static const _prescription = Prescription(
    examDate: '28/06/2026',
    durationDays: 7,
    medications: [
      Medication(
        name: 'Amlodipin',
        strength: '5mg · viên nén',
        days: '7 NGÀY',
        times: ['Sáng 08:00 · 1 viên'],
        note: 'Uống sau ăn. Không bỏ liều kể cả khi huyết áp đã ổn.',
      ),
      Medication(
        name: 'Metformin',
        strength: '500mg · viên nén',
        days: '7 NGÀY',
        times: ['Sáng 08:00 · 1 viên', 'Tối 20:00 · 1 viên'],
        note: 'Uống trong hoặc ngay sau bữa ăn để giảm kích ứng dạ dày.',
      ),
      Medication(
        name: 'Vitamin D3',
        strength: '1000 IU',
        days: '30 NGÀY',
        times: ['Trưa 12:00 · 1 viên'],
        note: 'Uống cùng bữa ăn có chất béo.',
      ),
    ],
  );

  // Today's reminder schedule matches the mockup (08:00 combines 2 pills, 12:00, 20:00).
  final List<MedicationDose> _doses = [
    const MedicationDose(
        time: '08:00',
        name: 'Amlodipin 5mg + Metformin 500mg',
        note: '2 viên · sau ăn sáng',
        taken: true),
    const MedicationDose(
        time: '12:00',
        name: 'Vitamin D3 1000 IU',
        note: '1 viên · cùng bữa trưa',
        taken: false),
    const MedicationDose(
        time: '20:00',
        name: 'Metformin 500mg',
        note: '1 viên · sau ăn tối',
        taken: false),
  ];

  @override
  Future<Result<Prescription>> getPrescription(String resultId) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(_prescription);
  }

  @override
  Future<Result<List<MedicationDose>>> getTodayDoses() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return Result.success(List.unmodifiable(_doses));
  }

  @override
  Future<Result<void>> markDoseTaken(int index, bool taken) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (index >= 0 && index < _doses.length) {
      _doses[index] = _doses[index].copyWith(taken: taken);
    }
    return const Result.success(null);
  }
}
