import 'package:dima_app/screens/change_password/change_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Change password screen test', () {
    testWidgets('ChangePasswordScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is TextFormField),
        findsNWidgets(3),
      );
    });
  });
}
