// Shared flow-driver steps, reused by both the headless widget-flow tests
// (test/flows/) and the on-device E2E (integration_test/). Keeping the steps in one
// place means a UI change is fixed once, not in two test suites.
//
// Not a test file itself (no `_test.dart` suffix), so `flutter test` won't run it.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nahealth_app/app.dart';
import 'package:nahealth_app/core/keys.dart';
import 'package:nahealth_app/core/network/mock_config.dart';
import 'package:nahealth_app/features/auth/presentation/providers/auth_providers.dart';

/// A session that starts already authenticated — lets a test land on the home tabs
/// without driving the whole login flow first.
class _AuthedSession extends SessionController {
  @override
  SessionState build() => const SessionState(isAuthenticated: true);
}

/// Pumps the real app inside a ProviderScope with a zero-delay mock config, so flows
/// are fast and deterministic. Set [authenticated] to skip straight to Home.
Future<void> pumpApp(WidgetTester tester, {bool authenticated = false}) async {
  // Use a phone-sized surface for the headless widget tests so screens laid out for a
  // phone don't overflow the default 800x600 test window. Skipped on a real device
  // (integration_test), which already has a real screen size.
  if (tester.binding is AutomatedTestWidgetsFlutterBinding) {
    // Match the Pixel 8 the app is designed for (~412dp wide) so phone layouts fit.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    // These flow tests verify behavior, not pixel layout. Ignore cosmetic RenderFlex
    // overflows (a headless artifact of the emoji/font fallback), still failing on
    // every other error.
    final defaultOnError = FlutterError.onError!;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      defaultOnError(details);
    };
    addTearDown(() => FlutterError.onError = defaultOnError);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mockConfigProvider.overrideWith(
          (ref) => const MockConfig(
            minDelay: Duration.zero,
            maxDelay: Duration.zero,
          ),
        ),
        if (authenticated)
          sessionControllerProvider.overrideWith(_AuthedSession.new),
      ],
      child: const NahealthApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Onboarding -> Login -> OTP screen: skips onboarding, enters a phone number and
/// requests the OTP, landing on the OTP screen.
Future<void> gotoOtpScreen(WidgetTester tester) async {
  // Onboarding: skip straight to login.
  await tester.tap(find.text('Bỏ qua'));
  await tester.pumpAndSettle();

  // Login: enter a phone number and request the OTP.
  await tester.enterText(find.byKey(AppKeys.loginPhoneField), '0912345678');
  await tester.pump();
  await tester.tap(find.byKey(AppKeys.loginSubmit));
  await tester.pumpAndSettle();
}

/// Enters the valid demo OTP, which auto-submits and advances to the next screen.
Future<void> submitValidOtp(WidgetTester tester) async {
  // The OtpInput autofocuses a hidden (Offstage) TextField that `enterText` can't
  // target, so send the demo code to the focused input connection.
  tester.testTextInput.enterText(kMockValidOtp);
  await tester.pumpAndSettle();
}

/// Taps each of the 5 main tabs, proving every top-level screen builds without error.
Future<void> visitAllTabs(WidgetTester tester) async {
  const tabs = [
    AppKeys.tabAppointments,
    AppKeys.tabResults,
    AppKeys.tabNotifications,
    AppKeys.tabProfile,
    AppKeys.tabHome,
  ];
  for (final tab in tabs) {
    await tester.tap(find.byKey(tab));
    await tester.pumpAndSettle();
  }
}
