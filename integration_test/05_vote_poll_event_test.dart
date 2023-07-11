import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/screens/poll_detail/components/date_tile.dart';
import 'package:dima_app/screens/poll_detail/components/invitee_votes_view.dart';
import 'package:dima_app/screens/poll_detail/components/location_tile.dart';
import 'package:dima_app/widgets/poll_event_tile.dart';
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
participant "Poll Detail Screen" as PollDetailScreen
participant "Location Detail" as LocationDetail
participant "Date Detail" as DateDetail
participant "Firebase Vote" as PollVoteService
participant "Firebase Firestore" as Firestore

User -> HomeScreen: Click on a poll tile
HomeScreen -> PollDetailScreen: Redirects to poll detail screen
User -> PollDetailScreen: Click on a location tile
PollDetailScreen -> LocationDetail: Opens location detail modal
User -> LocationDetail: Vote preferences
LocationDetail -> PollVoteService: Store preference
PollVoteService -> Firestore: Store preference
PollVoteService --> LocationDetail: Updated preferences
LocationDetail -> LocationDetail: Update preferences
User -> LocationDetail: Close modal
LocationDetail -> PollDetailScreen: Close modal

User -> PollDetailScreen: Click on "Dates" tab
User -> PollDetailScreen: Click on a date tile
PollDetailScreen -> DateDetail: Opens date detail modal
User -> DateDetail: Vote preferences
DateDetail -> PollVoteService: Store preference
PollVoteService -> Firestore: Store preference
PollVoteService --> DateDetail: Updated preferences
DateDetail -> DateDetail: Update preferences
User -> DateDetail: Close modal
DateDetail -> PollDetailScreen: Close modal

@enduml

*/
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
  });

  group('vote poll', () {
    testWidgets('vote an invited poll', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to poll home screen
      await tapOnWidgetByFinder(
          widget: find.byIcon(Icons.home, skipOffstage: false), tester: tester);
      // Go to invited
      await tapOnWidgetByFinder(widget: find.text("Invited"), tester: tester);
      expect(
        find.byWidgetPredicate((widget) => widget is PollEventTile),
        findsOneWidget,
      );

      // Go to poll_detail
      await tapOnWidgetByFinder(
        widget: find.text("Closed"),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.text("Open"),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.text("All"),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate((widget) =>
            widget is Icon && widget.icon == Icons.sort_by_alpha_outlined),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate((widget) =>
            widget is Icon && widget.icon == Icons.access_time_outlined),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate((widget) => widget is PollEventTile),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.refresh),
        tester: tester,
      );

      await tester.fling(
        find.text("Dates"),
        Offset(0, -150),
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      // Vote a location
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.sort_by_alpha),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.sort),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget:
            find.byWidgetPredicate((widget) => widget is LocationTile).first,
        tester: tester,
      );
      await tapOnWidgetByKey(key: "Attending", tester: tester);
      await closeModal(tester: tester);
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.check_circle),
        findsAtLeastNWidgets(2),
      );

      await tapOnWidgetByFinder(
          widget: find
              .byWidgetPredicate((widget) =>
                  widget is Icon && widget.icon == Icons.check_circle)
              .last,
          tester: tester);
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.help),
        findsAtLeastNWidgets(2),
      );

      // Vote a date
      await tapOnWidgetByFinder(widget: find.text("Dates"), tester: tester);
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate((widget) =>
            widget is Icon && widget.icon == Icons.access_time_outlined),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.sort),
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate((widget) => widget is DateTile).first,
        tester: tester,
      );
      await tapOnWidgetByKey(key: "Attending", tester: tester);
      await closeModal(tester: tester);
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.check_circle),
        findsAtLeastNWidgets(2),
      );

      await tapOnWidgetByFinder(
          widget: find
              .byWidgetPredicate((widget) =>
                  widget is Icon && widget.icon == Icons.check_circle)
              .last,
          tester: tester);
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.help),
        findsAtLeastNWidgets(2),
      );

      // see some details
      await tester.fling(
        find.text("Dates"),
        Offset(0, 150),
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tapOnWidgetByFinder(
          widget: find.textContaining(" invited"), tester: tester);
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.event_note)
            .first,
        tester: tester,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is InviteeVotesView),
        findsOneWidget,
      );
      await tapOnWidgetByFinder(widget: find.text("Dates"), tester: tester);
    });
  });
}
