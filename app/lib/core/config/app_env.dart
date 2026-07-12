/// Runtime environment for the app, resolved from `--dart-define` at build time so the
/// API host is never hardcoded and can differ per dev / staging / prod without code changes.
///
/// Example:
///   flutter run \
///     --dart-define=API_BASE_URL=http://10.0.2.2:5080/api/v1 \
///     --dart-define=USE_MOCK=false
///
/// Địa chỉ base URL theo nơi chạy BE:
///   - Android emulator gọi máy host qua 10.0.2.2
///   - iOS simulator qua localhost / 127.0.0.1
///   - Thiết bị thật qua IP LAN của máy chạy BE
class AppEnv {
  const AppEnv({
    required this.apiBaseUrl,
    required this.tenant,
    required this.useMock,
  });

  /// Base URL đã bao gồm prefix `/api/v1`.
  final String apiBaseUrl;

  /// Header `tenant` bắt buộc cho BE đa tenant (mặc định 'root').
  final String tenant;

  /// true = dùng Mock*Repository (chạy không cần BE); false = gọi API thật.
  final bool useMock;

  factory AppEnv.fromDartDefine() => const AppEnv(
        apiBaseUrl: String.fromEnvironment(
          'API_BASE_URL',
          // ⚠️ Chỉnh cổng cho khớp BE đang chạy.
          defaultValue: 'http://10.0.2.2:5080/api/v1',
        ),
        tenant: String.fromEnvironment('TENANT', defaultValue: 'root'),
        // Mặc định true cho an toàn: chưa truyền cờ thì app vẫn chạy mock.
        useMock: bool.fromEnvironment('USE_MOCK', defaultValue: true),
      );
}
