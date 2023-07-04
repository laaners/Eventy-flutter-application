import 'package:dima_app/screens/groups/components/create_group.dart';
import 'package:dima_app/screens/groups/components/edit_group.dart';
import 'package:dima_app/screens/groups/components/group_tile.dart';
import 'package:dima_app/screens/groups/components/groups_list.dart';
import 'package:dima_app/screens/groups/components/view_group.dart';
import 'package:dima_app/screens/groups/groups.dart';
import 'package:dima_app/screens/poll_create/components/step_invite.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
import 'package:dima_app/widgets/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../mocks/mock_firebase_groups.dart';
import '../../mocks/mock_firebase_user.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Edit profile screen test', () {
    testWidgets('CreateGroup component renders correctly', (tester) async {
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
                child: CreateGroup(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text("Group Name"),
        findsNWidgets(2),
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MyTextField),
        findsOneWidget,
      );
      expect(
        find.text("Members"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is StepInvite),
        findsOneWidget,
      );
    });

    testWidgets('EditGroup component renders correctly', (tester) async {
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
                child: EditGroup(group: MockFirebaseGroups.testGroupModel),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(MockFirebaseGroups.testGroupModel.groupName),
        findsNWidgets(2),
      );
      expect(
        find.text("Group Name"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is MyTextField),
        findsOneWidget,
      );
      expect(
        find.text("Members: 1"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is StepInvite),
        findsOneWidget,
      );
    });

    testWidgets('GroupTile component renders correctly', (tester) async {
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
                child: GroupTile(group: MockFirebaseGroups.testGroupModel),
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
        find.byWidgetPredicate((widget) => widget is ProfilePicsStack),
        findsOneWidget,
      );
    });

    testWidgets('GroupsList component renders correctly', (tester) async {
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
                child: Column(
                  children: [
                    GroupsList(searchController: TextEditingController()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is GroupTile),
        findsOneWidget,
      );
      expect(
        find.text(MockFirebaseGroups.testGroupModel.groupName),
        findsOneWidget,
      );
    });

    testWidgets('ViewGroup component renders correctly', (tester) async {
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
                child: ViewGroup(group: MockFirebaseGroups.testGroupModel),
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
        find.text("Members: 1"),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is UserTileFromData),
        findsOneWidget,
      );
    });

    testWidgets('GroupsScreen renders correctly', (tester) async {
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
            home: GroupsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is GroupsList),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is GroupTile),
        findsOneWidget,
      );

      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.group_add));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is CreateGroup),
          findsOneWidget);
      await tester.tap(find.byKey(Key("modal_cancel")));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.edit));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is EditGroup),
          findsOneWidget);
      await tester.tap(find.byKey(Key("modal_cancel")));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((widget) => widget is GroupTile));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is ViewGroup),
          findsOneWidget);
    });
  });
}
