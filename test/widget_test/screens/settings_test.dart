import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/screens/settings/components/profile_data.dart';
import 'package:dima_app/screens/settings/settings.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mocks/mock_clock_manager.dart';
import '../../mocks/mock_firebase_notification.dart';
import '../../mocks/mock_firebase_user.dart';
import '../../mocks/mock_theme_manager.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Settings screen test', () {
    testWidgets('SettingsScreen renders correctly', (tester) async {
      SharedPreferences.setMockInitialValues({
        'isPush': true,
        'isDark': true,
        'is24Hour': true,
      });
      await Preferences.init();
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
            ChangeNotifierProvider<ThemeManager>(
              create: (context) => MockThemeManger(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is ProfileData),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is SwitchListTile),
        findsNWidgets(3),
      );
      expect(
        find.byWidgetPredicate((widget) => widget is ListTile),
        findsAtLeastNWidgets(3),
      );
    });
  });
}
