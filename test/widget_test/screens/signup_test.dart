import 'package:dima_app/screens/signup/signup.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Signup screen test', () {
    testWidgets('SignupScreen renders correctly with button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is TextFormField),
        findsNWidgets(6),
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MyButton),
        findsOneWidget,
      );
    });
  });
}
