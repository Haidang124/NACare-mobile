import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared mock configuration for every repository while there is no real API yet.
///
/// Per the checklist in docs/product/ui-ux-app-benh-nhan.md section 7: "fake delay +
/// fake error toggled from the mock repository to test loading/error states". Turn on
/// [forceError]/[forceEmpty] from a debug screen or a test to inspect those states
/// without a backend.
class MockConfig {
  const MockConfig({
    this.minDelay = const Duration(milliseconds: 400),
    this.maxDelay = const Duration(milliseconds: 900),
    this.errorRate = 0.0,
    this.forceError = false,
    this.forceEmpty = false,
  });

  final Duration minDelay;
  final Duration maxDelay;

  /// Probability (0..1) that a random call returns an error; used to probe the
  /// error state during demos.
  final double errorRate;

  /// Force every subsequent call to fail — toggled from a debug screen when needed.
  final bool forceError;

  /// Force the repository to return an empty list — used to check the empty state.
  final bool forceEmpty;

  MockConfig copyWith({
    Duration? minDelay,
    Duration? maxDelay,
    double? errorRate,
    bool? forceError,
    bool? forceEmpty,
  }) {
    return MockConfig(
      minDelay: minDelay ?? this.minDelay,
      maxDelay: maxDelay ?? this.maxDelay,
      errorRate: errorRate ?? this.errorRate,
      forceError: forceError ?? this.forceError,
      forceEmpty: forceEmpty ?? this.forceEmpty,
    );
  }

  Future<void> simulateDelay() {
    final spanMs = (maxDelay - minDelay).inMilliseconds;
    final extra = spanMs > 0 ? Random().nextInt(spanMs) : 0;
    return Future.delayed(minDelay + Duration(milliseconds: extra));
  }

  bool get shouldFail {
    if (forceError) return true;
    if (errorRate <= 0) return false;
    return Random().nextDouble() < errorRate;
  }
}

/// Global provider for [MockConfig] — override it in tests or from a debug screen
/// to toggle forceError/forceEmpty without touching repository code.
final mockConfigProvider =
    StateProvider<MockConfig>((ref) => const MockConfig());

/// Valid OTP used to demo the happy path while no real SMS gateway is wired.
///
/// Kept in [core] (not in `mock_auth_repository.dart`) so the OTP screen can show a
/// "demo code" to testers **without importing a Mock*Repository class** — preserving
/// the presentation ⇏ data/repositories boundary. Remove when real SMS is wired.
const String kMockValidOtp = '123456';
