import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/location_icons.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/groups/components/view_group.dart';
import 'package:dima_app/screens/home/components/poll_event_list_by_you.dart';
import 'package:dima_app/screens/home/components/poll_event_list_invited.dart';
import 'package:dima_app/screens/home/home.dart';
import 'package:dima_app/screens/poll_create/components/invite_group_tile.dart';
import 'package:dima_app/screens/poll_create/components/invite_groups.dart';
import 'package:dima_app/screens/poll_create/components/invite_profile_pic.dart';
import 'package:dima_app/screens/poll_create/components/invite_users.dart';
import 'package:dima_app/screens/poll_create/components/my_stepper.dart';
import 'package:dima_app/screens/poll_create/components/select_day_slots.dart';
import 'package:dima_app/screens/poll_create/components/select_location.dart';
import 'package:dima_app/screens/poll_create/components/select_location_address.dart';
import 'package:dima_app/screens/poll_create/components/select_slot.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:dima_app/widgets/search_tile.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../mocks/mock_clock_manager.dart';
import '../../mocks/mock_firebase_groups.dart';
import '../../mocks/mock_firebase_poll_event.dart';
import '../../mocks/mock_firebase_poll_event_invite.dart';
import '../../mocks/mock_firebase_user.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Poll create screen test', () {
    testWidgets('InviteGroupTile component renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebaseGroups>(
              create: (context) => MockFirebaseGroups(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: InviteGroupTile(
                  group: MockFirebaseGroups.testGroupModel,
                  icon: Icon(Icons.add),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(MockFirebaseGroups.testGroupModel.groupName),
        findsOneWidget,
      );
      expect(
        find.text(
            "${MockFirebaseGroups.testGroupModel.membersUids.length} members"),
        findsOneWidget,
      );
      await tester.tap(
        find.byWidgetPredicate((widget) => widget is InviteGroupTile),
      );

      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is ViewGroup),
          findsOneWidget);
    });

    testWidgets('InviteGroups component renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            Provider<FirebaseGroups>(
              create: (context) => MockFirebaseGroups(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: InviteGroups(
                  invitees: [],
                  addInvitee: (value) {},
                  removeInvitee: (value) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is InviteGroupTile),
          findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is SearchTile),
        findsOneWidget,
      );
      await tester.enterText(
          find.byWidgetPredicate((widget) => widget is SearchTile),
          "non existent group");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is InviteGroupTile),
          findsNothing);
    });

    testWidgets('InviteProfilePic component renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: InviteProfilePic(
                  addInvitee: (value) {},
                  removeInvitee: (value) {},
                  addMode: true,
                  invitees: [],
                  user: UserModel(
                    uid: 'test uid2',
                    email: 'test email',
                    username: 'test username',
                    name: 'test name',
                    surname: 'test surname',
                    profilePic: 'default',
                  ),
                  originalInvitees: [],
                  organizerUid: "organizerUid",
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.add_circle),
          findsOneWidget);
    });

    testWidgets('InviteUsers component renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: InviteUsers(
                  addInvitee: (value) {},
                  removeInvitee: (value) {},
                  invitees: [],
                  organizerUid: "organizerUid",
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is InviteProfilePic),
          findsNothing);
      expect(
        find.byWidgetPredicate((widget) => widget is SearchTile),
        findsOneWidget,
      );
      await tester.enterText(
          find.byWidgetPredicate((widget) => widget is SearchTile),
          "should return 1 profile pic");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is InviteProfilePic),
          findsOneWidget);
    });

    testWidgets('MyStepper component renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: MyStepper(
                steps: [
                  MyStep(
                    isActive: true,
                    title: const Text(""),
                    label: const Text("Step 1"),
                    content: Text("Step 1 content"),
                  ),
                  MyStep(
                    isActive: false,
                    title: const Text(""),
                    label: const Text("Step 2"),
                    content: Text("Step 2 content"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Step 1"), findsOneWidget);
      expect(find.text("Step 2"), findsOneWidget);

      expect(find.text("Step 1 content"), findsOneWidget);
      expect(find.text("Step 2 content"), findsNothing);
    });

    testWidgets('SelectDaySlots component renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: SelectDaySlots(
                  day: DateTime.now(),
                  dates: {},
                  addDate: (value) {},
                  removeDate: (value) {},
                  setSlot: (value) {},
                  removeEmpty: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Add another time slot"), findsOneWidget);
      expect(find.text("No time slots selected for this day"), findsOneWidget);

      await tester.tap(find.text("Add another time slot"));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is SelectSlot),
          findsOneWidget);
    });

    testWidgets('SelectLocation component renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: SelectLocation(
                addLocation: (value) {},
                removeLocation: (value) {},
                locations: [],
                defaultLocation: Location("", "", 0, 0, "location_on_outlined"),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is IconButton),
        findsNWidgets(LocationIcons.icons.entries.length),
      );
      expect(find.text("Name"), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is MyTextField),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is SelectLocationAddress),
        findsOneWidget,
      );
    });

    testWidgets('SelectLocationAddress component renders correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: SelectLocationAddress(
                controller: TextEditingController(),
                setAddress: (value) {},
                setCoor: (value) {},
                defaultLocation: Location("", "", 0, 0, "location_on_outlined"),
                focusNode: FocusNode(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is ListTile),
        findsNothing,
      );
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
