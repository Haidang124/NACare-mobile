// Headless widget-flow test: with an authenticated session, taps through all 5 main
// tabs. If any top-level screen throws while building, this fails — so no one has to
// open each tab by hand to catch a regression.

import 'package:flutter_test/flutter_test.dart';

import '../support/flow_steps.dart';

void main() {
  testWidgets('authenticated user can navigate all 5 main tabs',
      (tester) async {
    await pumpApp(tester, authenticated: true);

    await visitAllTabs(tester);

    expect(tester.takeException(), isNull);
  });
}
