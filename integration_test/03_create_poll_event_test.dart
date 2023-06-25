import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_app/main.dart' as app;

import '02_login_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('create poll', () {
    testWidgets('create poll without invites', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await loginTest(tester: tester, username: "Ale", password: "password");

      // Go to poll create screen
      final createIcon = find.byKey(const Key("create_poll_event"));
      expect(createIcon, findsOneWidget);
      await tester.tap(createIcon);
      await tester.pumpAndSettle();
      expect(find.text("Basics"), findsOneWidget);

      // Fill basics
      final pollEventTitle = find.byKey(const Key('poll_event_title'));
      expect(pollEventTitle, findsOneWidget);
      await tester.enterText(pollEventTitle, "An event name");
      await tester.testTextInput
          .receiveAction(TextInputAction.done); // close keyboard

      final pollEventDesc = find.byKey(const Key('poll_event_desc'));
      expect(pollEventDesc, findsOneWidget);
      await tester.enterText(pollEventDesc,
          "An event description, this is the event 'An event name'");
      await tester.testTextInput
          .receiveAction(TextInputAction.done); // close keyboard

      final pollEventDeadline =
          find.widgetWithText(ListTile, "Deadline for voting");
      expect(pollEventDeadline, findsOneWidget);
      await tester.tap(pollEventDeadline);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("modal_confirm")));
      await tester.pumpAndSettle();

      // Fill places
      await tester.tap(find.widgetWithText(SizedBox, "Places").first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SizedBox, "Dates").first);
      await tester.pumpAndSettle();
      expect(find.text("Same time for all dates"), findsOneWidget);
    });
  });
}
