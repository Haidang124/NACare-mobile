import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../data/models/linked_patient_match.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';

/// Switch to the real API: change only this line; all screens/providers below stay the same.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(ref.watch(mockConfigProvider));
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
  SessionState build() => const SessionState();

  void completeLogin() => state = state.copyWith(isAuthenticated: true);
  void logout() => state = const SessionState(isAuthenticated: false);
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
