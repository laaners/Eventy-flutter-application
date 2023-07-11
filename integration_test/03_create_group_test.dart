import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/screens/groups/components/group_tile.dart';
import 'package:dima_app/screens/groups/components/view_group.dart';
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
participant "Groups Screen" as GroupsScreen
participant "Group Create" as GroupCreate
participant "Firebase Groups" as GroupService
participant "Firebase Firestore" as Firestore

User -> GroupsScreen: Create new group
GroupsScreen -> GroupCreate: Opens create group modal
User -> GroupCreate: Enters group details
User -> GroupCreate: Create group
GroupCreate -> GroupService: Create group
GroupService -> Firestore: Store group
GroupService --> GroupCreate: Storing success
User -> GroupCreate: Close modal
GroupCreate -> GroupsScreen: Close modal
GroupsScreen -> GroupsScreen: Shows groups
@enduml

*/
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
  });

  group('create group', () {
    testWidgets('create new group', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to groups screen
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.group)
            .first,
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.group_add)
            .first,
        tester: tester,
      );
      await fillTextWidgetByKey(
        key: "group_name",
        text: "A group name",
        tester: tester,
      );
      await fillTextWidgetByKey(
        key: "search_for_username",
        text: "username",
        tester: tester,
      );
      await tester.pumpAndSettle();
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
                (widget) => widget is Icon && widget.icon == Icons.add_circle)
            .at(2),
        tester: tester,
      );

      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);
      expect(find.byWidgetPredicate((widget) => widget is GroupTile),
          findsOneWidget);
      expect(find.text("A group name"), findsOneWidget);

      await tapOnWidgetByFinder(
        widget: find.byWidgetPredicate((widget) => widget is GroupTile),
        tester: tester,
      );
      expect(find.byWidgetPredicate((widget) => widget is ViewGroup),
          findsOneWidget);
    });

    testWidgets('edit existing group', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to groups screen
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.group)
            .first,
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.edit)
            .first,
        tester: tester,
      );
      expect(
        find.text(
          "Editing \"A group name\"",
        ),
        findsOneWidget,
      );
      await fillTextWidgetByKey(
        key: "group_name",
        text: "A group name edited",
        tester: tester,
      );
      await fillTextWidgetByKey(
        key: "search_for_username",
        text: "username",
        tester: tester,
      );
      await tester.pumpAndSettle();
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
                (widget) => widget is Icon && widget.icon == Icons.add_circle)
            .at(2),
        tester: tester,
      );

      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);
      expect(find.byWidgetPredicate((widget) => widget is GroupTile),
          findsOneWidget);
      expect(find.text("A group name edited"), findsOneWidget);
    });

    testWidgets('delete existing group', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      var usernameField = find.byKey(const Key('username_field'));
      if (usernameField.evaluate().isNotEmpty) {
        await loginTest(tester: tester, username: "Ale", password: "password");
      }

      // Go to groups screen
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.group)
            .first,
        tester: tester,
      );
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.edit)
            .first,
        tester: tester,
      );
      expect(
        find.text(
          "Editing \"A group name edited\"",
        ),
        findsOneWidget,
      );
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.delete)
            .first,
        tester: tester,
      );
      await tapOnWidgetByKey(key: "alert_confirm", tester: tester);
      expect(find.text("A group name edited"), findsNothing);

      // recreate it for later use
      await tapOnWidgetByFinder(
        widget: find
            .byWidgetPredicate(
                (widget) => widget is Icon && widget.icon == Icons.group_add)
            .first,
        tester: tester,
      );
      await fillTextWidgetByKey(
        key: "group_name",
        text: "A group name",
        tester: tester,
      );
      await fillTextWidgetByKey(
        key: "search_for_username",
        text: "username",
        tester: tester,
      );
      await tester.pumpAndSettle();
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
                (widget) => widget is Icon && widget.icon == Icons.add_circle)
            .at(2),
        tester: tester,
      );

      await tapOnWidgetByKey(key: "modal_confirm", tester: tester);
    });
  });
}
