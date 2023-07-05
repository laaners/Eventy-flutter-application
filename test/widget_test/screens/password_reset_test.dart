import 'package:dima_app/screens/password_reset/password_reset.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Password reset screen test', () {
    testWidgets('PasswordResetScreen renders correctly with button',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordResetScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is TextFormField),
        findsNWidgets(1),
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MyButton),
        findsOneWidget,
      );
    });
  });
}
