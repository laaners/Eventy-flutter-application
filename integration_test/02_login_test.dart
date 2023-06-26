import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_app/main.dart' as app;

import '00_utils.dart';

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

Future logoutTest({required WidgetTester tester}) async {
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
}

void main() {
/*
Paste the following here: https://www.plantuml.com/plantuml/uml/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000

@startuml
actor User
participant "Login Screen" as LoginScreen
participant "Firebase User" as FirebaseAuth
participant "Firebase Firestore" as Firestore

User -> LoginScreen: Enters username and password
LoginScreen -> FirebaseAuth: Request login
FirebaseAuth -> FirebaseAuth: Authenticate user
alt User authenticated
    FirebaseAuth -> Firestore: Get user data
    FirebaseAuth --> LoginScreen: User data
    LoginScreen -> User: Display user data
    LoginScreen -> HomeScreen: Redirect to home screen
else User not authenticated
    LoginScreen -> LoginScreen: Display authentication failure
end
@enduml
*/
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('login test', () {
    testWidgets('login and logout', (tester) async {
      await app.main();
      await loginTest(tester: tester, username: "Ale", password: "password");
      await logoutTest(tester: tester);
    });
    testWidgets('login fail', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // Enter data
      await fillTextWidget(
          key: "username_field",
          text: "This username does not exist",
          tester: tester);
      await fillTextWidget(
          key: "password_field", text: "random password", tester: tester);

      // Tap the signup button.
      await tapOnWidget(key: "login_button", tester: tester);

      // Wait for the Snackbar to appear
      final successSnackbar = find.text('Username does not exist');
      await tester.pump(const Duration(seconds: 3));
      expect(successSnackbar, findsAtLeastNWidgets(1));
    });
  });
}
