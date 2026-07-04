import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/security_settings.dart';
import 'security_repository.dart';

class MockSecurityRepository implements SecurityRepository {
  MockSecurityRepository(this._config);

  final MockConfig _config;

  List<SecurityToggle> _toggles = const [
    SecurityToggle(
        id: 'pin',
        icon: '🔒',
        label: 'Khóa bằng mã PIN',
        sub: 'Yêu cầu PIN mỗi khi mở app',
        enabled: true),
    SecurityToggle(
        id: 'bio',
        icon: '🫆',
        label: 'Face ID / vân tay',
        sub: 'Mở khóa nhanh bằng sinh trắc học',
        enabled: false),
    SecurityToggle(
        id: 'hide',
        icon: '🙈',
        label: 'Ẩn nội dung khi chuyển app',
        sub: 'Che màn hình trong danh sách ứng dụng gần đây',
        enabled: true),
  ];

  static const _devices = [
    LoggedInDevice(
        id: 'd1',
        icon: '📱',
        name: 'iPhone 15 — thiết bị này',
        info: 'Vinh, Nghệ An · Đang hoạt động',
        isCurrent: true),
    LoggedInDevice(
        id: 'd2',
        icon: '💻',
        name: 'Chrome trên Windows',
        info: 'Đăng nhập lần cuối 20/06/2026',
        isCurrent: false),
  ];

  List<ConsentItem> _consents = const [
    ConsentItem(
        id: 'care',
        label: 'Chăm sóc y tế',
        sub: 'Liên kết hồ sơ bệnh án, đặt lịch, trả kết quả',
        enabled: true,
        locked: true),
    ConsentItem(
        id: 'remind',
        label: 'Nhắc lịch & nhắc thuốc',
        sub: 'Gửi thông báo nhắc lịch khám và uống thuốc',
        enabled: true),
    ConsentItem(
        id: 'research',
        label: 'Nghiên cứu y khoa (ẩn danh)',
        sub: 'Dữ liệu ẩn danh phục vụ nghiên cứu của bệnh viện',
        enabled: false),
    ConsentItem(
        id: 'marketing',
        label: 'Thông tin ưu đãi',
        sub: 'Nhận thông tin gói khám, chương trình khuyến mãi',
        enabled: false),
  ];

  @override
  Future<Result<List<SecurityToggle>>> getToggles() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return Result.success(List.unmodifiable(_toggles));
  }

  @override
  Future<Result<void>> setToggle(String id, bool enabled) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    _toggles = _toggles
        .map((t) => t.id == id ? t.copyWith(enabled: enabled) : t)
        .toList();
    return const Result.success(null);
  }

  @override
  Future<Result<List<LoggedInDevice>>> getDevices() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(_devices);
  }

  @override
  Future<Result<void>> logoutDevice(String id) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(null);
  }

  @override
  Future<Result<List<ConsentItem>>> getConsentItems() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return Result.success(List.unmodifiable(_consents));
  }

  @override
  Future<Result<void>> setConsent(String id, bool enabled) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    _consents = _consents
        .map((c) => c.id == id && !c.locked ? c.copyWith(enabled: enabled) : c)
        .toList();
    return const Result.success(null);
  }

  @override
  Future<Result<void>> requestDataDeletion() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(null);
  }
}
