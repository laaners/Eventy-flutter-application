import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_app/main.dart' as app;

import '00_utils.dart';

void main() {
/*
Paste the following here: https://www.plantuml.com/plantuml/uml/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000

@startuml
actor User
participant "Login Screen" as LoginScreen
participant "Signup Screen" as SignupScreen
participant "Firebase User" as FirebaseAuth
participant "Firebase Firestore" as Firestore

User -> LoginScreen: Taps on signup button
LoginScreen -> SignupScreen: Redirects to signup screen
User -> SignupScreen: Fills user data
SignupScreen -> FirebaseAuth: Request signup
FirebaseAuth -> FirebaseAuth: Authenticate user
alt User authenticated
    FirebaseAuth -> Firestore: Get user data
    FirebaseAuth --> SignupScreen: User data
    SignupScreen -> HomeScreen: Redirects to home screen
else User not authenticated
    FirebaseAuth --> SignupScreen: Authentication failure
    SignupScreen -> SignupScreen: Display authentication failure
end
@enduml
*/
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('sign up test', () {
    testWidgets('sign up new user and sign out', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await tapOnWidgetByKey(key: "log_in_to_sign_up_screen", tester: tester);

      // We are in signup
      String username = "Ale";
      await fillTextWidgetByKey(
          key: 'username_field', text: username, tester: tester);
      await fillTextWidgetByKey(
          key: 'name_field', text: 'Alessio', tester: tester);
      await fillTextWidgetByKey(
          key: 'surname_field', text: 'Hu', tester: tester);
      await fillTextWidgetByKey(
          key: 'email_field', text: 'aletest@example.com', tester: tester);
      await fillTextWidgetByKey(
          key: 'password_field', text: 'password', tester: tester);
      await fillTextWidgetByKey(
          key: 'password_confirm_field', text: 'password', tester: tester);

      // Tap the signup button
      await tapOnWidgetByKey(key: 'signup_button', tester: tester);

      // We are in home, verify that the signup process was successful.
      // Wait for the Snackbar to appear
      final successSnackbar =
          find.text('Welcome, $username!'); // Wait for the Snackbar to appear
      // await tester.pumpAndSettle(Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 3));
      expect(successSnackbar, findsAtLeastNWidgets(1));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await logoutTest(tester: tester);
    });

    testWidgets('sign up old user', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await tapOnWidgetByKey(key: "log_in_to_sign_up_screen", tester: tester);

      // We are in signup
      String username = "Ale";
      await fillTextWidgetByKey(
          key: 'username_field', text: username, tester: tester);
      await fillTextWidgetByKey(
          key: 'name_field', text: 'Alessio', tester: tester);
      await fillTextWidgetByKey(
          key: 'surname_field', text: 'Hu', tester: tester);
      await fillTextWidgetByKey(
          key: 'email_field', text: 'aletest@example.com', tester: tester);
      await fillTextWidgetByKey(
          key: 'password_field', text: 'password', tester: tester);
      await fillTextWidgetByKey(
          key: 'password_confirm_field', text: 'password', tester: tester);

      // Duplicate username
      await tapOnWidgetByKey(key: 'signup_button', tester: tester);
      var successDuplicateWarning = find
          .text('Choose another username!'); // Wait for the Snackbar to appear
      await tester.pump(const Duration(seconds: 3));
      expect(successDuplicateWarning, findsAtLeastNWidgets(1));
      await tester.pumpAndSettle();

      // Change username
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await fillTextWidgetByKey(
          key: 'username_field', text: 'Ale2', tester: tester);
      await tapOnWidgetByKey(key: 'signup_button', tester: tester);
      successDuplicateWarning =
          find.text('Choose another email!'); // Wait for the Snackbar to appear
      await tester.pump(const Duration(seconds: 3));
      expect(successDuplicateWarning, findsAtLeastNWidgets(1));
    });
  });
}
