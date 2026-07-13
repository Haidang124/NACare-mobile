import 'package:flutter/foundation.dart';

/// Kết quả xác thực OTP thành công (map từ `PatientAuthResultDto` của BE).
///
/// Token đã được [ApiAuthRepository] lưu vào [TokenStore] ngay khi verify; ở đây chỉ
/// giữ cờ [profileLinked] để presentation quyết định điều hướng: đã liên kết hồ sơ HIS
/// thì vào thẳng bước tạo PIN, chưa thì rẽ sang màn liên kết hồ sơ (Flow A).
@immutable
class OtpVerifyResult {
  const OtpVerifyResult({required this.profileLinked});

  /// Tài khoản đã được liên kết với một hồ sơ bệnh nhân HIS hay chưa.
  final bool profileLinked;
}
