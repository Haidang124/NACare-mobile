// Headless widget-flow test: drives onboarding -> login -> OTP against mock data.
// Runs under `flutter test` (no device/emulator) and in CI on every PR — the automation
// that replaces manually opening the onboarding/login/OTP screens.
//
// The full happy path continues OTP -> matched-profile; that final screen is verified
// on a real device by integration_test/app_e2e_test.dart (its Column+Spacer layout needs
// a real screen, not the headless surface).

import 'package:flutter_test/flutter_test.dart';

import '../support/flow_steps.dart';

void main() {
  testWidgets('onboarding -> login -> reaches the OTP screen', (tester) async {
    await pumpApp(tester);
    await gotoOtpScreen(tester);

    // The OTP screen shows the demo-code hint once we're on it.
    expect(find.textContaining('Mã OTP thử nghiệm'), findsOneWidget);
  });
}
