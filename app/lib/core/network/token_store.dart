import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lưu access / refresh token của bệnh nhân vào bộ nhớ an toàn của thiết bị
/// (Keychain trên iOS, EncryptedSharedPreferences trên Android).
///
/// Token do BE cấp sau khi verify OTP (`PatientAuthResultDto`). Refresh token
/// **xoay vòng** mỗi lần refresh nên luôn ghi đè cả hai bằng cặp mới nhất.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccess = 'patient_access_token';
  static const _kRefresh = 'patient_refresh_token';

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  /// Có phiên đăng nhập đã lưu hay chưa (dùng để bootstrap session lúc mở app).
  Future<bool> get hasSession async => (await accessToken)?.isNotEmpty ?? false;

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
