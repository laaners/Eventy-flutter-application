import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_app/main.dart' as app;

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

  group('create poll', () {
    testWidgets('create poll without invites', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to poll create screen
      var createIcon = find.byKey(const Key("create_poll_event"));
      expect(createIcon, findsOneWidget);
      await tester.tap(createIcon);
      await tester.pumpAndSettle();
      expect(find.text("Basics"), findsOneWidget);

      // Fill basics
      await fillTextWidget(
          key: "poll_event_title", text: "An event name", tester: tester);
      await fillTextWidget(
          key: "poll_event_desc",
          text: "An event description, this is the event 'An event name'",
          tester: tester);
      var pollEventDeadline =
          find.widgetWithText(ListTile, "Deadline for voting");
      expect(pollEventDeadline, findsOneWidget);
      await tester.tap(pollEventDeadline);
      await tester.pumpAndSettle();
      await tapOnWidget(key: "modal_confirm", tester: tester);

      // Fill places
      await tester.tap(find.widgetWithText(SizedBox, "Places").first);
      await tester.pumpAndSettle();
      // Add virtual
      var virtualMeetingSwitch =
          find.byKey(const Key("virtual_meeting_switch"));
      expect(virtualMeetingSwitch, findsOneWidget);
      Switch virtualMeetingSwitchWidget = tester.widget(virtualMeetingSwitch);
      expect(virtualMeetingSwitchWidget.value, false);
      await tester.tap(virtualMeetingSwitch);
      await tester.pumpAndSettle();
      await tapOnWidget(key: "modal_confirm", tester: tester);
      await tapOnWidget(key: "alert_cancel", tester: tester);
      await fillTextWidget(
          key: "virtual_link_field",
          text: "https://meet.google.com/non-existent",
          tester: tester);
      await tapOnWidget(key: "modal_confirm", tester: tester);
      virtualMeetingSwitch = find.byKey(const Key("virtual_meeting_switch"));
      virtualMeetingSwitchWidget = tester.widget(virtualMeetingSwitch);
      expect(virtualMeetingSwitchWidget.value, true);
      // Real place
      await tapOnWidget(key: "add_location_tile", tester: tester);
      await fillTextWidget(
          key: "location_name_field", text: 'Polimi', tester: tester);

      // Fill dates
      await tester.tap(find.widgetWithText(SizedBox, "Dates").first);
      await tester.pumpAndSettle();
      expect(find.text("Same time for all dates"), findsOneWidget);
    });
  });
}
