import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/linked_patient_match.dart';
import '../models/otp_verify_result.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._config);

  final MockConfig _config;

  @override
  Future<Result<String?>> sendOtp(String phone) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.network());
    // Bản mock "lộ" luôn mã demo qua cùng kênh debugOtp để màn OTP hiện gợi ý.
    return const Result.success(kMockValidOtp);
  }

  @override
  Future<Result<OtpVerifyResult>> verifyOtp(
      {required String phone, required String otp}) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.network());
    if (otp != kMockValidOtp) {
      return const Result.failure(
          AppFailure('Mã OTP không đúng. Vui lòng kiểm tra lại.'));
    }
    // Bản mock luôn coi là chưa liên kết ⇒ demo đầy đủ luồng tìm + liên kết hồ sơ.
    return const Result.success(OtpVerifyResult(profileLinked: false));
  }

  @override
  Future<Result<void>> checkSession() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.network());
    return const Result.success(null);
  }

  @override
  Future<Result<List<LinkedPatientMatch>>> searchHisProfiles({
    required String citizenId,
    String? fullName,
    DateTime? dateOfBirth,
  }) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    // forceEmpty ⇒ không tìm thấy hồ sơ nào (để thử nhánh "tạo hồ sơ mới").
    if (_config.forceEmpty) return const Result.success([]);
    return const Result.success([
      LinkedPatientMatch(
        hisPatientCode: 'NA0018292',
        maskedName: 'Nguyễn Văn A***',
        maskedBirthYear: '19**',
        gender: 'Nam',
        maskedPhone: '09****678',
        matchLevel: 'Exact',
        initials: 'NA',
      ),
    ]);
  }

  @override
  Future<Result<String>> linkProfile(String hisPatientCode) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    // Trả về id trùng hồ sơ "bản thân" của mock (p1) để các màn phía sau nhất quán.
    return const Result.success('p1');
  }

  @override
  Future<Result<void>> setPin(String pin) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(null);
  }
}
