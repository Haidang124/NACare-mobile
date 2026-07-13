import '../../../../core/network/result.dart';
import '../models/linked_patient_match.dart';
import '../models/otp_verify_result.dart';

/// Tách UI đăng nhập khỏi cách hệ thống thật xác thực OTP / tra cứu HIS.
/// Presentation chỉ gọi các hàm này, không biết phía sau là mock hay API thật.
abstract class AuthRepository {
  /// Gửi OTP đăng nhập tới số điện thoại. `POST /patient/auth/otp`.
  /// Trả `debugOtp` nếu BE bật lộ mã (Development/Staging hoặc `PatientOtp:ExposeDebugOtp`);
  /// null ở môi trường thật — dùng để hiện gợi ý mã khi test.
  Future<Result<String?>> sendOtp(String phone);

  /// Xác thực OTP. Token được lưu ngay trong repo; trả cờ [OtpVerifyResult.profileLinked]
  /// để presentation biết đã liên kết hồ sơ HIS chưa. `POST /patient/auth/otp/verify`.
  Future<Result<OtpVerifyResult>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Kiểm tra token còn hợp lệ (dùng khi bootstrap phiên lúc mở app). `GET /patient/me`.
  Future<Result<void>> checkSession();

  /// Tìm hồ sơ HIS để liên kết — theo CCCD, kèm họ tên/ngày sinh nếu có (Flow A).
  /// `POST /patient/his-search`.
  Future<Result<List<LinkedPatientMatch>>> searchHisProfiles({
    required String citizenId,
    String? fullName,
    DateTime? dateOfBirth,
  });

  /// Liên kết tài khoản đang đăng nhập với một hồ sơ HIS; trả về `profileId` vừa tạo.
  /// `POST /patient/link-profile`.
  Future<Result<String>> linkProfile(String hisPatientCode);

  /// PIN mở khoá cục bộ trên máy (không thuộc API) — xử lý riêng sau.
  Future<Result<void>> setPin(String pin);
}
