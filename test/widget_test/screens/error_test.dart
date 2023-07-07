import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/logo.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_firebase_notification.dart';
import '../../mocks/mock_firebase_user.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Error screen test', () {
    testWidgets('ErrorScreen renders correctly with button', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
          ],
          child: MaterialApp(
            home: ErrorScreen(),
          ),
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
  });
}
