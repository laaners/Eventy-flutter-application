import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dima_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('sign up', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      /*

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byKey(const Key("test1")));
      await tester.pump();
      */

      expect(find.text('Eventy'), findsOneWidget);
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.tap(find.byKey(const Key("log-in-to-sign-up-screen")));

      /*

      // Verify the counter starts at 0.
      expect(find.text('0'), findsOneWidget);

      // Finds the floating action button to tap on.
      final Finder fab = find.byTooltip('Increment');

      // Emulate a tap on the floating action button.
      await tester.tap(fab);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify the counter increments by 1.
      expect(find.text('1'), findsOneWidget);
      */
    });
  });
}
