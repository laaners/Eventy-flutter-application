import 'package:dima_app/constants/preferences.dart';
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
participant "Poll Create Screen" as PollCreateScreen
participant "Stepper Widget" as StepperWidget
participant "Poll Service" as PollService

User -> PollCreateScreen: Starts creating a new poll
User -> PollCreateScreen: Enters poll details
PollCreateScreen -> StepperWidget: Displays stepper widget
User -> StepperWidget: Proceeds to the next step
StepperWidget -> PollCreateScreen: Returns entered details for the step
User -> StepperWidget: Proceeds to the next step
StepperWidget -> PollCreateScreen: Returns entered details for the step
User -> StepperWidget: Proceeds to the next step
StepperWidget -> PollCreateScreen: Returns entered details for the step
User -> StepperWidget: Proceeds to the next step
StepperWidget -> PollCreateScreen: Returns entered details for the step
PollCreateScreen -> PollService: Creates the poll
PollService --> PollCreateScreen: Poll creation result
PollCreateScreen -> User: Displays poll creation result
@enduml

*/
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
  });

  group('create poll', () {
    testWidgets('create poll without invites', (tester) async {
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

      // Fill basics
      await fillTextWidget(
          key: "poll_event_title", text: "An event name", tester: tester);
      await fillTextWidget(
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

      // Fill places
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
      await fillTextWidget(
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
      await fillTextWidget(
          key: "location_name_field", text: 'Polimi', tester: tester);
      await fillTextWidget(
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
      await fillTextWidget(
          key: "location_name_field",
          text: 'Politecnico di Milano',
          tester: tester);
      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);

      // Fill dates
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
      int hourPreferences = (DateTime.now().hour + 1).toInt();
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

      /*
      minFinder = find.text(hourPreferences.toString()).first;
      await tapOnWidgetByFinder(
          widget: find.text("Add another time slot"), tester: tester);
       */

      await tapOnWidgetByFinder(
          widget: find.text((DateTime.now().day % 28 + 1).toString()),
          tester: tester);
    });
  });
}
