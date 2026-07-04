import '../../../../core/network/result.dart';
import '../models/linked_patient_match.dart';

/// Decouples the login UI from how the real system verifies OTP / looks up the HIS.
/// Presentation only calls these methods, unaware of the mock or real API behind them.
abstract class AuthRepository {
  Future<Result<void>> sendOtp(String phone);

  /// Returns the HIS profile matching the phone number (null if none → create a new profile).
  Future<Result<LinkedPatientMatch?>> verifyOtp(
      {required String phone, required String otp});

  Future<Result<void>> linkProfile();
  Future<Result<void>> createNewProfile();
  Future<Result<void>> setPin(String pin);
}
