import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../../core/network/token_store.dart';
import '../../../../core/utils/formatting.dart';
import '../models/linked_patient_match.dart';
import '../models/otp_verify_result.dart';
import 'auth_repository.dart';

/// Bản thật của [AuthRepository] — gọi cụm `/patient/*` của BE.
///
/// Endpoint (BE base đã gồm `/api/v1`, header `tenant` gắn sẵn ở dioProvider):
///   POST /patient/auth/otp          → gửi OTP
///   POST /patient/auth/otp/verify   → xác thực, trả PatientAuthResultDto (token + profileLinked)
///   GET  /patient/me                → kiểm tra token còn sống
///   POST /patient/his-search        → tìm hồ sơ HIS theo CCCD (Flow A)
///   POST /patient/link-profile      → liên kết hồ sơ HIS, trả ProfileDto
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  @override
  Future<Result<String?>> sendOtp(String phone) => apiCall(
        () => _dio.post('/patient/auth/otp', data: {'phoneNumber': phone}),
        // OtpChallengeDto: chỉ lấy debugOtp (nếu BE lộ mã để test); phần còn lại bỏ qua.
        (json) => (json as Map)['debugOtp'] as String?,
      );

  @override
  Future<Result<OtpVerifyResult>> verifyOtp({
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

    return Result.success(
      OtpVerifyResult(profileLinked: (data['profileLinked'] as bool?) ?? false),
    );
  }

  @override
  Future<Result<void>> checkSession() =>
      apiCallVoid(() => _dio.get('/patient/me'));

  @override
  Future<Result<List<LinkedPatientMatch>>> searchHisProfiles({
    required String citizenId,
    String? fullName,
    DateTime? dateOfBirth,
  }) =>
      apiCall(
        () => _dio.post('/patient/his-search', data: {
          'citizenId': citizenId,
          if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
          if (dateOfBirth != null)
            // BE nhận DateOnly? — serialize "yyyy-MM-dd" (không lệ thuộc timezone).
            'dateOfBirth': DateFormat('yyyy-MM-dd').format(dateOfBirth),
        }),
        (json) => (json as List)
            .map((e) => _mapCandidate((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<String>> linkProfile(String hisPatientCode) => apiCall(
        () => _dio.post('/patient/link-profile',
            data: {'hisPatientCode': hisPatientCode}),
        (json) => (json as Map)['id'].toString(),
      );

  @override
  Future<Result<void>> setPin(String pin) async {
    // PIN là cơ chế mở khoá cục bộ trên máy, không thuộc API — xử lý riêng sau.
    return const Result.success(null);
  }

  LinkedPatientMatch _mapCandidate(Map<String, dynamic> j) {
    final name = (j['displayName'] as String?) ?? '(Không rõ tên)';
    return LinkedPatientMatch(
      hisPatientCode: j['hisPatientCode'].toString(),
      maskedName: name,
      maskedBirthYear: (j['birthYear'] as num?)?.toInt().toString() ?? '—',
      gender: _mapGender(j['gender']),
      maskedPhone: (j['maskedPhoneNumber'] as String?) ?? '—',
      matchLevel: (j['matchLevel'] as String?) ?? '',
      initials: initialsFrom(name),
    );
  }

  /// Enum giới tính PersonalGender (Unknown/Male/Female/Other) — BE có thể trả số hoặc chuỗi.
  String _mapGender(dynamic v) {
    if (v is int) {
      return switch (v) { 1 => 'Nam', 2 => 'Nữ', 3 => 'Khác', _ => '—' };
    }
    return switch (v?.toString().toLowerCase()) {
      'male' => 'Nam',
      'female' => 'Nữ',
      'other' => 'Khác',
      _ => '—',
    };
  }
}
