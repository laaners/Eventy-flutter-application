import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/location_icons.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/groups/components/view_group.dart';
import 'package:dima_app/screens/poll_create/components/invite_group_tile.dart';
import 'package:dima_app/screens/poll_create/components/invite_groups.dart';
import 'package:dima_app/screens/poll_create/components/invite_profile_pic.dart';
import 'package:dima_app/screens/poll_create/components/invite_users.dart';
import 'package:dima_app/screens/poll_create/components/my_stepper.dart';
import 'package:dima_app/screens/poll_create/components/select_day_slots.dart';
import 'package:dima_app/screens/poll_create/components/select_location.dart';
import 'package:dima_app/screens/poll_create/components/select_location_address.dart';
import 'package:dima_app/screens/poll_create/components/select_slot.dart';
import 'package:dima_app/screens/poll_create/components/select_virtual.dart';
import 'package:dima_app/screens/poll_create/components/step_basics.dart';
import 'package:dima_app/screens/poll_create/components/step_dates.dart';
import 'package:dima_app/screens/poll_create/components/step_invite.dart';
import 'package:dima_app/screens/poll_create/components/step_places.dart';
import 'package:dima_app/screens/poll_create/poll_create.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:dima_app/widgets/search_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../mocks/mock_clock_manager.dart';
import '../../mocks/mock_firebase_groups.dart';
import '../../mocks/mock_firebase_notification.dart';
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

    testWidgets('SelectSlot component renders correctly', (tester) async {
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
                child: SelectSlot(
                  setSlot: (value) {},
                  dayString: "2023-06-20",
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is CupertinoDatePicker),
          findsNWidgets(2));
    });

    testWidgets('SelectVirtual component renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: SelectVirtual(
                defaultOptions: Location("", "", 1, 1, "videocam"),
                locations: [],
                addLocation: (value) {},
                removeLocation: (value) {},
                setVirtualMeeting: (value) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Virtual room link (optional)"), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is TextFormField),
        findsOneWidget,
      );
    });

    testWidgets('StepBasics component renders correctly', (tester) async {
      TextEditingController deadlineController = TextEditingController();
      DateTime now = DateTime.now();
      deadlineController.text = DateFormat("yyyy-MM-dd HH:00:00").format(
        DateTime(now.year, now.month, now.day + 1),
      );
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
                child: StepBasics(
                  eventTitleController: TextEditingController(),
                  eventDescController: TextEditingController(),
                  deadlineController: deadlineController,
                  setDeadline: (value) {},
                  dates: {},
                  removeDays: (value) {},
                  visibility: true,
                  changeVisibility: () {},
                  canInvite: true,
                  changeCanInvite: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Title"), findsOneWidget);
      expect(find.text("Description (optional)"), findsOneWidget);
      expect(find.text("Deadline for voting"), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is MyTextField),
        findsNWidgets(2),
      );
      expect(
        find.byWidgetPredicate((widget) => widget is ListTile),
        findsOneWidget,
      );
      await tester.tap(find.byWidgetPredicate((widget) => widget is ListTile));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is MyModal),
        findsOneWidget,
      );
    });

    testWidgets('StepDates component renders correctly', (tester) async {
      TextEditingController deadlineController = TextEditingController();
      DateTime now = DateTime.now();
      deadlineController.text = DateFormat("yyyy-MM-dd HH:00:00").format(
        DateTime(now.year, now.month, now.day + 1),
      );
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
                child: ListView(
                  children: [
                    StepDates(
                      dates: {},
                      addDate: (value) {},
                      removeDate: (value) {},
                      deadlineController: deadlineController,
                      removeEmpty: (value) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is PillBox),
        findsOneWidget,
      );
      expect(
        find.text("Tap on a selected day to edit its time slots"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is TableCalendar),
        findsOneWidget,
      );
      await tester.tap(find.byKey(Key("same_slots_switch")));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is SelectSlot),
        findsOneWidget,
      );
      await tester.tap(find.byKey(Key("modal_confirm")));
      await tester.pumpAndSettle();
      expect(
        find.text("Long tap on a selected day to edit its time slots"),
        findsOneWidget,
      );
    });

    testWidgets('StepInvite component renders correctly', (tester) async {
      TextEditingController deadlineController = TextEditingController();
      DateTime now = DateTime.now();
      deadlineController.text = DateFormat("yyyy-MM-dd HH:00:00").format(
        DateTime(now.year, now.month, now.day + 1),
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseGroups>(
              create: (context) => MockFirebaseGroups(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: ListView(
                  children: [
                    StepInvite(
                      invitees: [],
                      addInvitee: (value) {},
                      removeInvitee: (value) {},
                      organizerUid: "organizerUid",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is InviteProfilePic),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.byWidgetPredicate((widget) => widget is TabBar),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is InviteUsers),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is InviteGroups),
        findsNothing,
      );

      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.group_add));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is InviteUsers),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is InviteGroups),
        findsOneWidget,
      );
    });

    testWidgets('StepPlaces component renders correctly', (tester) async {
      List<Location> locations = [];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ListView(
                children: [
                  StepPlaces(
                    locations: locations,
                    addLocation: (value) {
                      locations.add(value);
                    },
                    removeLocation: (value) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is PillBox),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MyListTile),
        findsOneWidget,
      );

      await tester.tap(find.byKey(Key("virtual_meeting_switch")));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is SelectVirtual),
        findsOneWidget,
      );
      await tester.tap(find.byKey(Key("modal_confirm")));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("alert_confirm")));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is MyListTile),
        findsNWidgets(2),
      );

      await tester.tap(find.byKey(Key("add_location_tile")));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is SelectLocation),
        findsOneWidget,
      );
      await tester.tap(find.byKey(Key("modal_cancel")));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is MyListTile),
        findsNWidgets(2),
      );
    });

    testWidgets('PollCreateScreen renders correctly', (tester) async {
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
            ChangeNotifierProvider<ClockManager>(
              create: (context) => MockClockManager(),
            ),
            Provider<FirebaseGroups>(
              create: (context) => MockFirebaseGroups(),
            ),
          ],
          child: MaterialApp(
            home: PollCreateScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is MyStepper),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is StepBasics),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(SizedBox, "Places").first);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is StepPlaces),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(SizedBox, "Dates").first);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is StepDates),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(SizedBox, "Invite").first);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is StepInvite),
        findsOneWidget,
      );
    });
  });
}
