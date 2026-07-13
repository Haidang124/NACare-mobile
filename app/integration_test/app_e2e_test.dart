// On-device / on-emulator E2E test. Same flows as test/flows/, but driven through the
// real Flutter engine on a device via the integration_test binding.
//
// Run locally on the emulator:
//   flutter test integration_test/app_e2e_test.dart -d emulator-5554
//
// These are slower (a full app build + a real device) so they are NOT part of the
// per-PR CI; run them locally or on a nightly job (see .github/workflows/integration.yml).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/flow_steps.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: patient logs in, searches HIS and reaches the matched profile',
      (tester) async {
    await pumpApp(tester);
    await gotoOtpScreen(tester);
    await submitValidOtp(tester);

    // Chưa liên kết ⇒ vào màn nhập CCCD để tìm hồ sơ HIS.
    expect(find.text('Liên kết hồ sơ bệnh nhân'), findsOneWidget);

    // Nhập CCCD rồi tìm — mock trả về 1 hồ sơ khớp.
    await tester.enterText(find.byType(TextField).first, '040200013346');
    await tester.pump();
    await tester.tap(find.text('Tìm hồ sơ'));
    await tester.pumpAndSettle();

    expect(find.text('Tìm thấy hồ sơ của bạn'), findsOneWidget);
  });

  testWidgets('E2E: authenticated user navigates all 5 main tabs',
      (tester) async {
    await pumpApp(tester, authenticated: true);
    await visitAllTabs(tester);

    expect(tester.takeException(), isNull);
  });
}
