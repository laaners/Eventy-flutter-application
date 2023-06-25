import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_app/main.dart' as app;
import 'package:flutter/cupertino.dart';
import 'package:flutter_driver/flutter_driver.dart' as driver;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('sign up', (tester) async {
      await app.main();

      // We are in signup page
      await tester.pumpAndSettle();
      expect(find.text('Eventy'), findsOneWidget);
      final toSignUpButton = find.byKey(const Key("log_in_to_sign_up_screen"));
      await tester.tap(toSignUpButton);

      // We are in signup
      await tester.pumpAndSettle();
      expect(find.text('Already have an account?'), findsOneWidget);
      final usernameField = find.byKey(const Key('username_field'));
      final nameField = find.byKey(const Key('name_field'));
      final surnameField = find.byKey(const Key('surname_field'));
      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final passwordConfirmField =
          find.byKey(const Key('password_confirm_field'));
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
      // await tester.ensureVisible(signupButton);
      await tester.tap(signupButton);

      // We are in home, verify that the signup process was successful.
      // Wait for the Snackbar to appear
      final successSnackbar =
          find.text('Welcome, $username!'); // Wait for the Snackbar to appear
      // await tester.pumpAndSettle(Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 5));
      expect(successSnackbar, findsAtLeastNWidgets(1));
      await tester.pumpAndSettle();
    });
  });
}
