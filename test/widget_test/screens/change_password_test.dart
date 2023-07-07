import 'package:dima_app/screens/change_password/change_password.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_user.dart';
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

  group('Change password screen test', () {
    testWidgets('ChangePasswordScreen renders correctly', (tester) async {
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
            home: ChangePasswordScreen(),
          ),
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
