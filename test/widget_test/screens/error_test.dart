import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/widgets/logo.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Error screen test', () {
    testWidgets('ErrorScreen renders correctly with button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("AN ERROR HAS OCCURRED"), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is EventyLogo),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MyButton),
        findsOneWidget,
      );
    });

    testWidgets('ErrorScreen renders correctly without button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorScreen(noButton: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("AN ERROR HAS OCCURRED"), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is EventyLogo),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MyButton),
        findsNothing,
      );
    });
  });
}
