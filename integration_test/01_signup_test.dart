import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_app/main.dart' as app;
import 'package:flutter_driver/flutter_driver.dart' as driver;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('sign up test', () {
    testWidgets('sign up new user and sign out', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      final toSignUpButton = find.byKey(const Key("log_in_to_sign_up_screen"));
      expect(toSignUpButton, findsOneWidget);
      await tester.tap(toSignUpButton);

      // We are in signup
      await tester.pumpAndSettle();
      final usernameField = find.byKey(const Key('username_field'));
      expect(usernameField, findsOneWidget);

      final nameField = find.byKey(const Key('name_field'));
      expect(nameField, findsOneWidget);

      final surnameField = find.byKey(const Key('surname_field'));
      expect(surnameField, findsOneWidget);

      final emailField = find.byKey(const Key('email_field'));
      expect(emailField, findsOneWidget);

      final passwordField = find.byKey(const Key('password_field'));
      expect(passwordField, findsOneWidget);

      final passwordConfirmField =
          find.byKey(const Key('password_confirm_field'));
      expect(passwordConfirmField, findsOneWidget);

      final signupButton = find.byKey(const Key('signup_button'));
      expect(signupButton, findsOneWidget);

      // Enter data
      String username = "Ale";
      await tester.enterText(usernameField, username);
      await tester.enterText(nameField, 'Alessio');
      await tester.enterText(surnameField, 'Hu');
      await tester.enterText(emailField, 'aletest@example.com');
      await tester.enterText(passwordField, 'password');
      await tester.enterText(passwordConfirmField, 'password');
      await tester.testTextInput
          .receiveAction(TextInputAction.done); // close keyboard
      await tester.pumpAndSettle();

      // Tap the signup button.
      await tester.tap(signupButton);

      // We are in home, verify that the signup process was successful.
      // Wait for the Snackbar to appear
      final successSnackbar =
          find.text('Welcome, $username!'); // Wait for the Snackbar to appear
      // await tester.pumpAndSettle(Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 3));
      expect(successSnackbar, findsAtLeastNWidgets(1));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Sign out
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
    testWidgets('sign up old user', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      final toSignUpButton = find.byKey(const Key("log_in_to_sign_up_screen"));
      expect(toSignUpButton, findsOneWidget);
      await tester.tap(toSignUpButton);

      // We are in signup
      await tester.pumpAndSettle();
      final usernameField = find.byKey(const Key('username_field'));
      expect(usernameField, findsOneWidget);

      final nameField = find.byKey(const Key('name_field'));
      expect(nameField, findsOneWidget);

      final surnameField = find.byKey(const Key('surname_field'));
      expect(surnameField, findsOneWidget);

      final emailField = find.byKey(const Key('email_field'));
      expect(emailField, findsOneWidget);

      final passwordField = find.byKey(const Key('password_field'));
      expect(passwordField, findsOneWidget);

      final passwordConfirmField =
          find.byKey(const Key('password_confirm_field'));
      expect(passwordConfirmField, findsOneWidget);

      final signupButton = find.byKey(const Key('signup_button'));
      expect(signupButton, findsOneWidget);

      // Enter data
      String username = "Ale";
      await tester.enterText(usernameField, username);
      await tester.enterText(nameField, 'Alessio');
      await tester.enterText(surnameField, 'Hu');
      await tester.enterText(emailField, 'aletest@example.com');
      await tester.enterText(passwordField, 'password');
      await tester.enterText(passwordConfirmField, 'password');
      await tester.testTextInput
          .receiveAction(TextInputAction.done); // close keyboard
      await tester.pumpAndSettle();

      // Tap the signup button.
      await tester.tap(signupButton);

      // We are in home, verify that the signup process was successful.
      // Wait for the Snackbar to appear
      var successDuplicateWarning = find
          .text('Choose another username!'); // Wait for the Snackbar to appear
      await tester.pump(const Duration(seconds: 3));
      expect(successDuplicateWarning, findsAtLeastNWidgets(1));
      await tester.pumpAndSettle();

      // Change username
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(find.byKey(const Key('username_field')), 'Ale2');
      await tester.testTextInput
          .receiveAction(TextInputAction.done); // close keyboard
      await tester.pumpAndSettle();
      await tester.tap(signupButton);

      successDuplicateWarning =
          find.text('Choose another email!'); // Wait for the Snackbar to appear
      await tester.pump(const Duration(seconds: 3));
      expect(successDuplicateWarning, findsAtLeastNWidgets(1));
    });
  });
}
