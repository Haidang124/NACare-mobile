import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/config_providers.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/auth_events.dart';
import '../../../../core/network/mock_config.dart';
import '../../../../core/network/token_store.dart';
import '../../data/models/linked_patient_match.dart';
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
    if (await ref.read(tokenStoreProvider).hasSession) {
      state = state.copyWith(isAuthenticated: true);
    }
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
  const AuthFlowState({this.phone = '', this.match, this.isNewProfile = false});

  final String phone;
  final LinkedPatientMatch? match;
  final bool isNewProfile;

  AuthFlowState copyWith(
      {String? phone,
      LinkedPatientMatch? match,
      bool? isNewProfile,
      bool clearMatch = false}) {
    return AuthFlowState(
      phone: phone ?? this.phone,
      match: clearMatch ? null : (match ?? this.match),
      isNewProfile: isNewProfile ?? this.isNewProfile,
    );
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

  void setMatch(LinkedPatientMatch? match) {
    state = state.copyWith(
        match: match, clearMatch: match == null, isNewProfile: match == null);
  }

  void chooseCreateNewProfile() =>
      state = state.copyWith(isNewProfile: true, clearMatch: true);

  void reset() => state = const AuthFlowState();
}

final authFlowControllerProvider =
    NotifierProvider<AuthFlowController, AuthFlowState>(AuthFlowController.new);
