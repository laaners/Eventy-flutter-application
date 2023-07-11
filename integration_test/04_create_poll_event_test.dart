import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_app/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '00_utils.dart';

void main() {
/*
Paste the following here: https://www.plantuml.com/plantuml/uml/SyfFKj2rKt3CoKnELR1Io4ZDoSa70000

@startuml
actor User
participant "Home Screen" as HomeScreen
participant "Poll Create Screen" as PollCreateScreen
participant "Firebase PollEvent" as PollService
participant "Firebase Firestore" as Firestore

User -> HomeScreen: Starts creating a new poll
HomeScreen -> PollCreateScreen: Displays stepper widget
User -> PollCreateScreen: Enters basics details
User -> PollCreateScreen: Proceeds to the next step
User -> PollCreateScreen: Enters places details
User -> PollCreateScreen: Proceeds to the next step
User -> PollCreateScreen: Enters dates details
User -> PollCreateScreen: Proceeds to the next step
User -> PollCreateScreen: Enters invite details
User -> PollCreateScreen: Create poll
PollCreateScreen -> PollService: Create poll
PollService -> Firestore: Store poll
PollService --> PollCreateScreen: Storing success
PollCreateScreen -> HomeScreen: Redirects home screen
HomeScreen -> HomeScreen: Shows creation success
@enduml

*/
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
  });

  group('create poll', () {
    testWidgets('create a new poll', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to poll create screen
      await tapOnWidgetByFinder(
          widget: find.byKey(const Key("create_poll_event")), tester: tester);
      expect(find.text("Basics"), findsOneWidget);

      // Fill basics-------------------------------------------------------
      await fillTextWidgetByKey(
          key: "poll_event_title", text: "An event name", tester: tester);
      await fillTextWidgetByKey(
          key: "poll_event_desc",
          text: "An event description, this is the event 'An event name'",
          tester: tester);
      await tapOnWidgetByFinder(
          widget: find.widgetWithText(ListTile, "Deadline for voting"),
          tester: tester);
      var minFinder = find.text("00").first;
      const offset = Offset(0, -150);
      await tester.fling(
        minFinder,
        offset,
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);

      // Fill places-------------------------------------------------------
      await tapOnWidgetByFinder(
          widget: find.widgetWithText(SizedBox, "Places").first,
          tester: tester);
      // Add virtual
      var virtualMeetingSwitch =
          find.byKey(const Key("virtual_meeting_switch"));
      expect(virtualMeetingSwitch, findsOneWidget);
      Switch virtualMeetingSwitchWidget = tester.widget(virtualMeetingSwitch);
      expect(virtualMeetingSwitchWidget.value, false);
      await tester.tap(virtualMeetingSwitch);
      await tester.pumpAndSettle();
      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);
      await tapOnWidgetByKey(key: "alert_cancel", tester: tester);
      await fillTextWidgetByKey(
          key: "virtual_link_field",
          text: "https://meet.google.com/non-existent",
          tester: tester);
      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);
      virtualMeetingSwitch = find.byKey(const Key("virtual_meeting_switch"));
      expect(virtualMeetingSwitch, findsOneWidget);
      virtualMeetingSwitchWidget = tester.widget(virtualMeetingSwitch);
      expect(virtualMeetingSwitchWidget.value, true);
      // Real place
      await tapOnWidgetByKey(key: "add_location_tile", tester: tester);
      await fillTextWidgetByKey(
          key: "location_name_field", text: 'Polimi', tester: tester);
      await fillTextWidgetByKey(
          key: "location_addr_field",
          text: 'politecnico di mi',
          tester: tester);
      await tester.pumpAndSettle();
      await tapOnWidgetByFinder(
          widget: find.textContaining("Leonardo"), tester: tester);
      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);
      // Modify real place name
      await tapOnWidgetByFinder(
          widget: find.textContaining("Polimi"), tester: tester);
      await fillTextWidgetByKey(
          key: "location_name_field",
          text: 'Politecnico di Milano',
          tester: tester);
      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);

      // Fill dates-------------------------------------------------------
      await tapOnWidgetByFinder(
          widget: find.widgetWithText(SizedBox, "Dates").first, tester: tester);
      expect(find.text("Same time for all dates"), findsOneWidget);
      // same time
      var sameSlotsSwitch = find.byKey(const Key("same_slots_switch"));
      expect(sameSlotsSwitch, findsOneWidget);
      Switch sameSlotsSwitchWidget = tester.widget(sameSlotsSwitch);
      expect(sameSlotsSwitchWidget.value, false);
      await tester.tap(sameSlotsSwitch);
      await tester.pumpAndSettle();
      // select a global slot
      int hourPreferences;
      hourPreferences = (DateTime.now().hour + 1).toInt();
      if (!Preferences.getBool("is24Hour")) {
        hourPreferences = hourPreferences >= 1 && hourPreferences <= 12
            ? hourPreferences
            : hourPreferences - 12;
        hourPreferences =
            hourPreferences < 0 ? -hourPreferences : hourPreferences;
      }
      await tester.fling(
        minFinder,
        offset,
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);

      sameSlotsSwitch = find.byKey(const Key("same_slots_switch"));
      expect(sameSlotsSwitch, findsOneWidget);
      sameSlotsSwitchWidget = tester.widget(sameSlotsSwitch);
      expect(sameSlotsSwitchWidget.value, true);
      await tester.pumpAndSettle();

      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate((widget) =>
            widget is MyListTile && widget.title == "Add another time slot"),
        tester: tester,
      );
      hourPreferences = (DateTime.now().hour + 1).toInt();
      if (!Preferences.getBool("is24Hour")) {
        hourPreferences = hourPreferences >= 1 && hourPreferences <= 12
            ? hourPreferences
            : hourPreferences - 12;
        hourPreferences =
            hourPreferences < 0 ? -hourPreferences : hourPreferences;
      }
      await tester.fling(
        minFinder,
        Offset(0, -180),
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);

      await tapOnWidgetByFinder(
        widget: find.text((DateTime.now().day % 28 + 1).toString()).last,
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.text((DateTime.now().day % 28 + 2).toString()).last,
        tester: tester,
      );

      // long press
      await tester.longPress(
        find.text((DateTime.now().day % 28 + 2).toString()).last,
      );
      await tester.pumpAndSettle();
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate((widget) =>
                widget is MyListTile && widget.title == "Add another time slot")
            .last,
        tester: tester,
      );
      hourPreferences = (DateTime.now().hour + 1).toInt();
      if (!Preferences.getBool("is24Hour")) {
        hourPreferences = hourPreferences >= 1 && hourPreferences <= 12
            ? hourPreferences
            : hourPreferences - 12;
        hourPreferences =
            hourPreferences < 0 ? -hourPreferences : hourPreferences;
      }
      await tester.fling(
        minFinder,
        Offset(0, -210),
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);
      await closeModal(tester: tester);

      // Fill invite-------------------------------------------------------
      await tapOnWidgetByFinder(
        widget: find.widgetWithText(SizedBox, "Invite").first,
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.group_add),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.add_circle)
            .first,
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.cancel)
            .first,
        tester: tester,
      );

      // Create poll-------------------------------------------------------
      await tapOnWidgetByFinder(
        widget: find.widgetWithText(SizedBox, "Invite").first,
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate(
            (widget) => widget is MyButton && widget.text == "Create"),
        tester: tester,
      );
      final homeIcon = find.byIcon(Icons.home, skipOffstage: false);
      await tester.tap(homeIcon);
      await tester.pumpAndSettle();
      expect(find.text("An event name"), findsOneWidget);

      // Close poll-------------------------------------------------------
      await tapOnWidgetByFinder(
          widget: find
              .byWidgetPredicate(
                  (widget) => widget is Icon && widget.icon == Icons.more_vert)
              .first,
          tester: tester);
      await tapOnWidgetByFinder(
          widget: find.text("Close the poll").first, tester: tester);
      await tapOnWidgetByKey(key: "alert_confirm", tester: tester);
      expect(find.text("An event name"), findsOneWidget);

      // Delete event-------------------------------------------------------
      await tapOnWidgetByFinder(
          widget: find
              .byWidgetPredicate(
                  (widget) => widget is Icon && widget.icon == Icons.more_vert)
              .first,
          tester: tester);
      await tapOnWidgetByFinder(
          widget: find.text("Delete the event").first, tester: tester);
      await tapOnWidgetByKey(key: "alert_confirm", tester: tester);
      expect(find.text("An event name"), findsNothing);
    });
  });
}
