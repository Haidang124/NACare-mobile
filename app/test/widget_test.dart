// Basic smoke test: the app builds without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nahealth_app/app.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NahealthApp()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
