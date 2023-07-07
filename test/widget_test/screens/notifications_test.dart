import 'package:dima_app/screens/notifications/components/notification_tile.dart';
import 'package:dima_app/screens/notifications/notifications.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../mocks/mock_firebase_notification.dart';
import '../../mocks/mock_firebase_poll_event.dart';
import '../../mocks/mock_firebase_poll_event_invite.dart';
import '../../mocks/mock_firebase_user.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Notifcations screen test', () {
    testWidgets('NotificationTile component renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: NotificationTile(
                    notification:
                        MockFirebaseNotification.testPollEventNotification),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is MyListTile),
        findsOneWidget,
      );
      expect(
        find.text(MockFirebaseNotification.testPollEventNotification.title),
        findsOneWidget,
      );
      expect(
        find.text(MockFirebaseNotification.testPollEventNotification.body),
        findsOneWidget,
      );
    });

    testWidgets('NotificationsScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebasePollEvent>(
              create: (context) => MockFirebasePollEvent(),
            ),
            Provider<FirebasePollEventInvite>(
              create: (context) => MockFirebasePollEventInvite(),
            ),
          ],
          child: MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("No notifications"), findsOneWidget);
    });
  });
}
