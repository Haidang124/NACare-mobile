import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/config_providers.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/auth_events.dart';
import '../../../../core/network/mock_config.dart';
import '../../../../core/network/token_store.dart';
import '../../data/repositories/api_auth_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';

/// Mock hay API thật là do cờ [useMockProvider] (từ --dart-define=USE_MOCK) quyết định.
/// Screens/providers phía dưới không đổi.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(useMockProvider)) {
    return MockAuthRepository(ref.watch(mockConfigProvider));
  }
  return ApiAuthRepository(ref.watch(dioProvider), ref.watch(tokenStoreProvider));
});

// ─────────────────────────── Session (logged in or not) ───────────────────────────

class SessionState {
  const SessionState({this.isAuthenticated = false});
  final bool isAuthenticated;

  SessionState copyWith({bool? isAuthenticated}) {
    return SessionState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated);
  }
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    // Mất phiên (401 → refresh thất bại) do tầng network phát tín hiệu ⇒ tự đăng xuất.
    ref.listen(unauthorizedSignalProvider, (_, __) {
      state = const SessionState(isAuthenticated: false);
    });
    // Bootstrap: đã có token lưu sẵn thì coi như đang đăng nhập (bỏ qua onboarding).
    _restore();
    return const SessionState();
  }

  Future<void> _restore() async {
    if (!await ref.read(tokenStoreProvider).hasSession) return;
    // Có token lưu sẵn nhưng phải xác nhận còn hợp lệ (GET /patient/me): token hết hạn
    // sẽ bị interceptor 401 xoá phiên; chỉ coi là đã đăng nhập khi /me trả 200.
    final ok = await ref.read(authRepositoryProvider).checkSession();
    state = state.copyWith(
      isAuthenticated: ok.when(success: (_) => true, failure: (_) => false),
    );
  }

  void completeLogin() => state = state.copyWith(isAuthenticated: true);

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const SessionState(isAuthenticated: false);
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

// ─────────────────────────── Auth flow (temporary data across steps) ───────────────────────────

class AuthFlowState {
  const AuthFlowState({this.phone = ''});

  final String phone;

  AuthFlowState copyWith({String? phone}) {
    return AuthFlowState(phone: phone ?? this.phone);
  }

  String get maskedPhone {
    if (phone.length < 4) return phone;
    return '+84 ${phone.substring(0, phone.length - 3).replaceAll(RegExp('.'), '*')}${phone.substring(phone.length - 3)}';
  }
}

class AuthFlowController extends Notifier<AuthFlowState> {
  @override
  AuthFlowState build() => const AuthFlowState();

  void setPhone(String phone) => state = state.copyWith(phone: phone);

  void reset() => state = const AuthFlowState();
}

final authFlowControllerProvider =
    NotifierProvider<AuthFlowController, AuthFlowState>(AuthFlowController.new);
