import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/screens/change_password/change_password.dart';
import 'package:dima_app/screens/edit_profile/edit_profile.dart';
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

  group('change settings', () {
    testWidgets('change isDark, is24Hour and isPush', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to settings screen
      await tapOnWidgetByFinder(
        widget: find.byIcon(Icons.settings, skipOffstage: false),
        tester: tester,
      );
      // Change isDark, is24Hour, isPush
      for (var i = 0; i < 3; i++) {
        var switchTile =
            find.byWidgetPredicate((widget) => widget is SwitchListTile).at(i);
        SwitchListTile switchTileWidget = tester.widget(switchTile);
        bool beforeValue = switchTileWidget.value;
        await tapOnWidgetByFinder(
          widget: find
              .byWidgetPredicate((widget) => widget is SwitchListTile)
              .at(i),
          tester: tester,
        );
        switchTile =
            find.byWidgetPredicate((widget) => widget is SwitchListTile).at(i);
        switchTileWidget = tester.widget(switchTile);
        expect(switchTileWidget.value, !beforeValue);
      }
    });

    testWidgets('edit profile', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to settings screen
      await tapOnWidgetByFinder(
        widget: find.byIcon(Icons.settings, skipOffstage: false),
        tester: tester,
      );
      // Go to edit profile
      await tapOnWidgetByFinder(
        widget: find.text("Edit profile"),
        tester: tester,
      );
      expect(find.byWidgetPredicate((widget) => widget is EditProfileScreen),
          findsOneWidget);
      await fillTextWidgetByFinder(
        widget:
            find.byWidgetPredicate((widget) => widget is TextFormField).first,
        text: "Ale2",
        tester: tester,
      );
      await tapOnWidgetByFinder(widget: find.text("SAVE"), tester: tester);
      var successSnackbar = find.text('Your information has been updated!');
      await tester.pump(const Duration(seconds: 3));
      expect(successSnackbar, findsAtLeastNWidgets(1));

      // set back to Ale
      await fillTextWidgetByFinder(
        widget:
            find.byWidgetPredicate((widget) => widget is TextFormField).first,
        text: "Ale",
        tester: tester,
      );
      await tapOnWidgetByFinder(widget: find.text("SAVE"), tester: tester);
      successSnackbar = find.text('Your information has been updated!');
      await tester.pump(const Duration(seconds: 3));
      expect(successSnackbar, findsAtLeastNWidgets(1));
    });

    testWidgets('change password', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to settings screen
      await tapOnWidgetByFinder(
        widget: find.byIcon(Icons.settings, skipOffstage: false),
        tester: tester,
      );
      // Go to change password
      await tapOnWidgetByFinder(
        widget: find.text("Change password"),
        tester: tester,
      );
      expect(find.byWidgetPredicate((widget) => widget is ChangePasswordScreen),
          findsOneWidget);
      await fillTextWidgetByFinder(
        widget:
            find.byWidgetPredicate((widget) => widget is TextFormField).at(0),
        text: "password",
        tester: tester,
      );

      // new password not matching
      await fillTextWidgetByFinder(
        widget:
            find.byWidgetPredicate((widget) => widget is TextFormField).at(1),
        text: "password",
        tester: tester,
      );
      await fillTextWidgetByFinder(
        widget:
            find.byWidgetPredicate((widget) => widget is TextFormField).at(2),
        text: "password1",
        tester: tester,
      );

      await fillTextWidgetByFinder(
        widget:
            find.byWidgetPredicate((widget) => widget is TextFormField).at(2),
        text: "password",
        tester: tester,
      );
      await tapOnWidgetByFinder(widget: find.text("SAVE"), tester: tester);
    });
  });
}
