import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../../core/network/token_store.dart';
import '../models/linked_patient_match.dart';
import 'auth_repository.dart';

/// Bản thật của [AuthRepository] — gọi cụm `/patient/auth/*` của BE.
///
/// Endpoint (BE base đã gồm `/api/v1`, header `tenant` gắn sẵn ở dioProvider):
///   POST /patient/auth/otp          → gửi OTP
///   POST /patient/auth/otp/verify   → xác thực, trả PatientAuthResultDto (access + refresh token)
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  @override
  Future<Result<void>> sendOtp(String phone) => apiCallVoid(
        () => _dio.post('/patient/auth/otp', data: {'phoneNumber': phone}),
      );

  @override
  Future<Result<LinkedPatientMatch?>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final res = await apiCall<Map<String, dynamic>>(
      () => _dio.post('/patient/auth/otp/verify',
          data: {'phoneNumber': phone, 'otp': otp}),
      (json) => (json as Map).cast<String, dynamic>(),
    );

    if (res is Failure<Map<String, dynamic>>) {
      return Result.failure(res.failure);
    }
    final data = (res as Success<Map<String, dynamic>>).data;

    // Lưu cặp token bệnh nhân; refresh token xoay vòng nên luôn ghi đè cả hai.
    await _tokens.save(
      access: data['accessToken'] as String,
      refresh: data['refreshToken'] as String,
    );

    // Việc tìm hồ sơ HIS để liên kết sẽ tra theo CCCD + SĐT — tạm bỏ qua trong đợt này
    // (xem memory patient-link-by-cccd). Trả null ⇒ luồng đi nhánh "tạo hồ sơ mới".
    return const Result.success(null);
  }

  @override
  Future<Result<void>> linkProfile() async => const Result.failure(
        AppFailure(
          'Tính năng liên kết hồ sơ đang được hoàn thiện.',
          retryable: false,
        ),
      );

  @override
  Future<Result<void>> createNewProfile() async {
    // Tài khoản bệnh nhân được BE tạo tự động ngay khi verify OTP thành công,
    // nên bước này hiện là no-op. Khi có luồng khai báo hồ sơ mới sẽ gọi endpoint tương ứng.
    return const Result.success(null);
  }

  @override
  Future<Result<void>> setPin(String pin) async {
    // PIN là cơ chế mở khoá cục bộ trên máy, không thuộc API — xử lý riêng sau.
    return const Result.success(null);
  }
}
