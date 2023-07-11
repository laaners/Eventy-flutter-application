import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/screens/notifications/components/notification_tile.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_app/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '00_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
  });

  group('manage notifications', () {
    testWidgets('open a notification', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to notifications screen
      await tapOnWidgetByFinder(
        widget: find.byIcon(Icons.notifications, skipOffstage: false),
        tester: tester,
      );
      // open a notification
      await tester.pump(Duration(seconds: 3));
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate((widget) => widget is NotificationTile)
            .first,
        tester: tester,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is PollEventScreen),
        findsOneWidget,
      );
    });
  });
}
