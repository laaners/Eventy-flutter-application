import 'package:dima_app/screens/home/components/poll_event_list_body.dart';
import 'package:dima_app/screens/home/components/poll_event_list_by_you.dart';
import 'package:dima_app/screens/home/components/poll_event_list_invited.dart';
import 'package:dima_app/screens/home/home.dart';
import 'package:dima_app/screens/poll_detail/components/poll_event_options.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/poll_event_tile.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../mocks/mock_firebase_poll_event.dart';
import '../../mocks/mock_firebase_poll_event_invite.dart';
import '../../mocks/mock_firebase_user.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Home screen test', () {
    testWidgets('PollEventListBody component renders correctly',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebasePollEvent>(
              create: (context) => MockFirebasePollEvent(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: PollEventListBody(
                  events: [MockFirebasePollEvent.testPollEventModel],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is PollEventTile),
        findsOneWidget,
      );
      expect(
        find.text(MockFirebasePollEvent.testPollEventModel.pollEventName),
        findsOneWidget,
      );
      await tester.tap(
        find.byWidgetPredicate((widget) {
          return widget is Icon && widget.icon == Icons.more_vert;
        }),
      );

      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is PollEventOptions),
          findsOneWidget);
    });

    testWidgets('PollEventListByYou component renders correctly',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebasePollEvent>(
              create: (context) => MockFirebasePollEvent(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: PollEventListByYou(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is PollEventListBody),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is EmptyList),
        findsOneWidget,
      );
      expect(
        find.text("Create your first poll"),
        findsOneWidget,
      );
    });

    testWidgets('PollEventListInvited component renders correctly',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
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
            home: Scaffold(
              body: SafeArea(
                child: PollEventListInvited(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("No polls or events found"), findsOneWidget);
    });

    testWidgets('HomeScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
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
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is TabbarSwitcher),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is PollEventListByYou),
        findsOneWidget,
      );
      await tester.tap(find.text("Invited"));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is PollEventListInvited),
        findsOneWidget,
      );
    });
  });
}
