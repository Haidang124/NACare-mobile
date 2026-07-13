import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../models/security_settings.dart';
import 'security_repository.dart';

class ApiSecurityRepository implements SecurityRepository {
  ApiSecurityRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<SecurityToggle>>> getToggles() => apiCall(
        () => _dio.get('/patient/security/toggles'),
        (json) => (json as List)
            .map((e) => _mapToggle((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<void>> setToggle(String id, bool enabled) => apiCallVoid(
        () => _dio.put('/patient/security/toggles',
            data: {'key': id, 'enabled': enabled}),
      );

  @override
  Future<Result<List<LoggedInDevice>>> getDevices() => apiCall(
        () => _dio.get('/patient/security/devices'),
        (json) => (json as List)
            .map((e) => _mapDevice((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<void>> logoutDevice(String id) => apiCallVoid(
        () => _dio.post('/patient/security/devices/$id/logout'),
      );

  @override
  Future<Result<List<ConsentItem>>> getConsentItems() => apiCall(
        () => _dio.get('/patient/security/consents'),
        (json) => (json as List)
            .map((e) => _mapConsent((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<void>> setConsent(String id, bool enabled) => apiCallVoid(
        () => _dio.put('/patient/security/consents',
            data: {'documentVersionId': id, 'agree': enabled}),
      );

  @override
  Future<Result<void>> requestDataDeletion() => apiCallVoid(
        () => _dio.post('/patient/security/data-deletion'),
      );

  SecurityToggle _mapToggle(Map<String, dynamic> json) {
    final key = (json['key'] as String?) ?? '';
    return SecurityToggle(
      id: key,
      icon: _toggleIcon(key),
      label: _toggleLabel(key),
      sub: _toggleDescription(key),
      enabled: (json['enabled'] as bool?) ?? false,
    );
  }

  LoggedInDevice _mapDevice(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final userAgent = (json['userAgent'] as String?) ?? 'Thiết bị';
    final ip = json['ipAddress'] as String?;
    return LoggedInDevice(
      id: id,
      icon: userAgent.toLowerCase().contains('mobile') ? '📱' : '💻',
      name: userAgent,
      info: ip == null || ip.isEmpty ? 'Đang hoạt động' : 'IP $ip',
      isCurrent: false,
    );
  }

  ConsentItem _mapConsent(Map<String, dynamic> json) {
    final required = (json['required'] as bool?) ?? false;
    return ConsentItem(
      id: json['documentVersionId'].toString(),
      label: (json['title'] as String?) ?? 'Văn bản đồng ý',
      sub: 'Phiên bản ${(json['version'] as String?) ?? ''}'.trim(),
      enabled: (json['agreed'] as bool?) ?? false,
      locked: required,
    );
  }

  String _toggleIcon(String key) => switch (key) {
        'pin' => '🔒',
        'bio' || 'biometric' => '☝',
        'hide' || 'hideSensitiveData' => '🙈',
        _ => '🛡',
      };

  String _toggleLabel(String key) => switch (key) {
        'pin' => 'Khóa bằng mã PIN',
        'bio' || 'biometric' => 'Face ID / vân tay',
        'hide' || 'hideSensitiveData' => 'Ẩn nội dung khi chuyển app',
        _ => key,
      };

  String _toggleDescription(String key) => switch (key) {
        'pin' => 'Yêu cầu PIN mỗi khi mở app',
        'bio' || 'biometric' => 'Mở khóa nhanh bằng sinh trắc học',
        'hide' ||
        'hideSensitiveData' =>
          'Che nội dung trong danh sách ứng dụng gần đây',
        _ => 'Thiết lập bảo mật tài khoản',
      };
}
