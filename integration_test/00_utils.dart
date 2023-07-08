import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future tapOnWidgetByKey({
  required String key,
  required WidgetTester tester,
}) async {
  final widget = await find.byKey(Key(key));
  expect(widget, findsOneWidget);
  await tester.tap(widget);
  await tester.pumpAndSettle();
}

Future tapOnWidgetByFinder({
  required Finder widget,
  required WidgetTester tester,
}) async {
  expect(widget, findsOneWidget);
  await tester.tap(widget);
  await tester.pumpAndSettle();
}

Future fillTextWidgetByKey({
  required String key,
  required String text,
  required WidgetTester tester,
}) async {
  final widget = await find.byKey(Key(key));
  expect(widget, findsOneWidget);
  await tester.enterText(widget, text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

Future fillTextWidgetByFinder({
  required Finder widget,
  required String text,
  required WidgetTester tester,
}) async {
  expect(widget, findsOneWidget);
  await tester.enterText(widget, text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

Future loginTest({
  required WidgetTester tester,
  required String username,
  required String password,
}) async {
  final usernameField = find.byKey(const Key('username_field'));
  if (usernameField.evaluate().isEmpty) {
    tester.printToConsole("Already logged in");
    return;
  }
  expect(usernameField, findsOneWidget);

  final passwordField = find.byKey(const Key('password_field'));
  expect(passwordField, findsOneWidget);

  final loginButton = find.byKey(const Key('login_button'));
  expect(loginButton, findsOneWidget);

  // Enter data
  await tester.enterText(usernameField, username);
  await tester.enterText(passwordField, password);
  await tester.testTextInput
      .receiveAction(TextInputAction.done); // close keyboard
  await tester.pumpAndSettle();

  // Tap the signup button.
  // await tester.ensureVisible(loginButton);
  await tester.tap(loginButton);

  // We are in home, verify that the signup process was successful.
  // Wait for the Snackbar to appear
  final successSnackbar =
      find.text('Welcome, $username!'); // Wait for the Snackbar to appear
  // await tester.pumpAndSettle(Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 3));
  expect(successSnackbar, findsAtLeastNWidgets(1));
  // await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future logoutTest({required WidgetTester tester}) async {
  // Logout
  final settingsIcon = find.byIcon(Icons.settings, skipOffstage: false);
  if (settingsIcon.evaluate().isEmpty) {
    tester.printToConsole("Already logged out");
    return;
  }
  expect(settingsIcon, findsOneWidget);
  await tester.tap(settingsIcon);
  await tester.pumpAndSettle();
  final logoutIcon = find.byIcon(Icons.logout).first;
  expect(logoutIcon, findsOneWidget);
  await tester.tap(logoutIcon);
  await tester.pumpAndSettle();
  await tapOnWidgetByKey(key: "alert_confirm", tester: tester);
  expect(find.byKey(const Key("log_in_to_sign_up_screen")), findsOneWidget);
}

Future closeModal({required WidgetTester tester}) async {
  await tester.fling(
    find.byKey(Key("modal_drag_bar")),
    Offset(0, 210),
    1000,
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
}
