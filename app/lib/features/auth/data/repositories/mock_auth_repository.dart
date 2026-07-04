import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/linked_patient_match.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._config);

  final MockConfig _config;

  @override
  Future<Result<void>> sendOtp(String phone) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.network());
    return const Result.success(null);
  }

  @override
  Future<Result<LinkedPatientMatch?>> verifyOtp(
      {required String phone, required String otp}) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.network());
    if (otp != kMockValidOtp) {
      return const Result.failure(
          AppFailure('Mã OTP không đúng. Vui lòng kiểm tra lại.'));
    }
    if (_config.forceEmpty) return const Result.success(null);
    return const Result.success(
      LinkedPatientMatch(
        maskedName: 'Nguyễn Văn A***',
        patientCode: 'NA00****92',
        maskedBirthYear: '19**',
        gender: 'Nam',
        lastVisit: '03/2026',
        initials: 'NA',
      ),
    );
  }

  @override
  Future<Result<void>> linkProfile() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(null);
  }

  @override
  Future<Result<void>> createNewProfile() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(null);
  }

  @override
  Future<Result<void>> setPin(String pin) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(null);
  }
}
