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
      await tester.pumpAndSettle();
      await loginTest(tester: tester, username: "Ale", password: "password");
      await logoutTest(tester: tester);
    });

    testWidgets('login fail', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // Enter data
      await fillTextWidgetByKey(
          key: "username_field",
          text: "This username does not exist",
          tester: tester);
      await fillTextWidgetByKey(
          key: "password_field", text: "random password", tester: tester);

      // Tap the signup button.
      await tapOnWidgetByKey(key: "login_button", tester: tester);

      // Wait for the Snackbar to appear
      final successSnackbar = find.text('Username does not exist');
      await tester.pump(const Duration(seconds: 3));
      expect(successSnackbar, findsAtLeastNWidgets(1));
    });
  });
}
