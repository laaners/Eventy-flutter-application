import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_app/main.dart' as app;

Future loginTest({
  required WidgetTester tester,
  required String username,
  required String password,
}) async {
  await tester.pumpAndSettle();

  final usernameField = find.byKey(const Key('username_field'));
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('login test', () {
    testWidgets('login and logout', (tester) async {
      await app.main();

      await loginTest(tester: tester, username: "Ale", password: "password");

      // Logout
      final settingsIcon = find.byIcon(Icons.settings, skipOffstage: false);
      expect(settingsIcon, findsOneWidget);
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();
      final logoutIcon = find.byIcon(Icons.logout).first;
      expect(logoutIcon, findsOneWidget);
      await tester.tap(logoutIcon);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key("log_in_to_sign_up_screen")), findsOneWidget);
    });
    testWidgets('login fail', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      final usernameField = find.byKey(const Key('username_field'));
      expect(usernameField, findsOneWidget);

      final passwordField = find.byKey(const Key('password_field'));
      expect(passwordField, findsOneWidget);

      final loginButton = find.byKey(const Key('login_button'));
      expect(loginButton, findsOneWidget);

      // Enter data
      String username = "This username does not exist";
      await tester.enterText(usernameField, username);
      await tester.enterText(passwordField, 'password');
      await tester.testTextInput
          .receiveAction(TextInputAction.done); // close keyboard
      await tester.pumpAndSettle();

      // Tap the signup button.
      // await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);

      // We are in home, verify that the signup process was successful.
      // Wait for the Snackbar to appear
      final successSnackbar = find
          .text('Username does not exist'); // Wait for the Snackbar to appear
      // await tester.pumpAndSettle(Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 3));
      expect(successSnackbar, findsAtLeastNWidgets(1));
    });
  });
}
