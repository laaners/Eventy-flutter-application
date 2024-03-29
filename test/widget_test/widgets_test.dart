import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/poll_create/poll_create.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/container_shadow.dart';
import 'package:dima_app/widgets/delay_widget.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/logo.dart';
import 'package:dima_app/widgets/map_widget.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:dima_app/widgets/poll_event_tile.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:dima_app/widgets/search_tile.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:dima_app/widgets/tablet_navigation_rail.dart';
import 'package:dima_app/widgets/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_clock_manager.dart';
import '../mocks/mock_firebase_groups.dart';
import '../mocks/mock_firebase_notification.dart';
import '../mocks/mock_firebase_user.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('widgets folder test', () {
    testWidgets('ContainerShadow has a text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ContainerShadow(
                child: Text("Hello", textDirection: TextDirection.ltr),
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                width: 200,
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('DelayWidget has a text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: DelayWidget(
                child: Text("Hello"),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('EmptyList has a title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: EmptyList(
                emptyMsg: "Hello",
                title: "This is a title",
                button: Text("This is another text",
                    textDirection: TextDirection.ltr),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('This is a title'), findsOneWidget);
      expect(find.text('This is another text'), findsOneWidget);
    });

    testWidgets('HorizontalScroller has 10 containers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: HorizontalScroller(
                children: [
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Container && widget.color == Colors.orange),
          findsNWidgets(10));
    });

    testWidgets('LoadingLogo has the logo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: LoadingLogo(),
            ),
          ),
        ),
      );
      expect(find.byWidgetPredicate((widget) => widget is EventyLogo),
          findsOneWidget);
    });

    testWidgets('LoadingOverlay shows loading', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
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
                child: Builder(builder: (context) {
                  return Column(
                    children: [
                      ElevatedButton(
                        key: Key("test button1"),
                        child: Text("Show loading and hide"),
                        onPressed: () async {
                          LoadingOverlay.show(context);
                          await Future.delayed(Duration(seconds: 3));
                          LoadingOverlay.hide(context);
                        },
                      ),
                      ElevatedButton(
                        key: Key("test button2"),
                        child: Text("Show loading and not hide"),
                        onPressed: () {
                          LoadingOverlay.show(context);
                        },
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("test button1")));
      await tester.pump(Duration(seconds: 1));
      expect(
        find.byWidgetPredicate((widget) => widget is EventyLogo),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is EventyLogo),
        findsNothing,
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("test button2")));
      await tester.pumpAndSettle(Duration(seconds: 5));
      expect(
        find.text("AN ERROR HAS OCCURRED"),
        findsOneWidget,
      );
    });

    testWidgets('Logo renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: EventyLogo(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is EventyLogo),
          findsOneWidget);
    });

    testWidgets('MapFromCoor has a marker', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: MapFromCoor(
                lat: 46.258603,
                lon: 10.508,
                address: "address",
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is MapFromCoor),
          findsOneWidget);

      expect(find.byWidgetPredicate((widget) => widget is MarkerLayer),
          findsOneWidget);
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.place),
          findsOneWidget);
      var mapFinder = find.byWidgetPredicate((widget) => widget is MapFromCoor);
      const offset = Offset(0, -550);
      await tester.fling(
        mapFinder,
        offset,
        1000,
        warnIfMissed: false,
      );
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.place),
          findsNothing);
    });

    testWidgets('MyAlertDialog renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      key: Key("test button1"),
                      child: Text("Show cancel"),
                      onPressed: () async {
                        await MyAlertDialog.showAlertIfCondition(
                          context: context,
                          condition: true,
                          title: "MyAlertDialog title",
                          content: "MyAlertDialog content",
                        );
                      },
                    ),
                    ElevatedButton(
                      key: Key("test button2"),
                      child: Text("Show confirm cancel"),
                      onPressed: () async {
                        await MyAlertDialog.showAlertConfirmCancel(
                          context: context,
                          trueButtonText: "Confirm text",
                          title: "MyAlertDialog title",
                          content: "MyAlertDialog content",
                        );
                      },
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("test button1")));
      await tester.pumpAndSettle();
      expect(find.text('MyAlertDialog title'), findsOneWidget);
      await tester.tap(find.byKey(Key("alert_ok")));
      await tester.pumpAndSettle();
      expect(find.text('MyAlertDialog title'), findsNothing);

      await tester.tap(find.byKey(Key("test button2")));
      await tester.pumpAndSettle();
      expect(find.text('Confirm text'), findsOneWidget);
      await tester.tap(find.byKey(Key("alert_confirm")));
      await tester.pumpAndSettle();
      expect(find.text('MyAlertDialog title'), findsNothing);
    });

    testWidgets('MyAppBar has a title', (tester) async {
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
            home: Scaffold(
              appBar: MyAppBar(
                title: "AppBar title",
                upRightActions: [
                  Builder(builder: (context) {
                    return MyAppBar.createEvent(context);
                  })
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('AppBar title'), findsOneWidget);
      await tester
          .tap(find.byWidgetPredicate((widget) => widget is MyIconButton));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is PollCreateScreen),
          findsOneWidget);
    });

    testWidgets('MyButton has a text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return MyButton(
                  text: "MyButton text",
                  onPressed: () async {
                    await MyAlertDialog.showAlertIfCondition(
                      context: context,
                      condition: true,
                      title: "MyAlertDialog title",
                      content: "MyAlertDialog content",
                    );
                  },
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('MYBUTTON TEXT'), findsOneWidget);
      await tester.tap(find.byWidgetPredicate((widget) => widget is MyButton));
      await tester.pumpAndSettle();
      expect(find.text('MyAlertDialog title'), findsOneWidget);
    });

    testWidgets('MyIconButton as an icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return MyIconButton(
                  icon: Icon(Icons.abc),
                  onTap: () async {
                    await MyAlertDialog.showAlertIfCondition(
                      context: context,
                      condition: true,
                      title: "MyAlertDialog title",
                      content: "MyAlertDialog content",
                    );
                  },
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.abc),
          findsOneWidget);
      await tester
          .tap(find.byWidgetPredicate((widget) => widget is MyIconButton));
      await tester.pumpAndSettle();
      expect(find.text('MyAlertDialog title'), findsOneWidget);
    });

    testWidgets('MyListTile renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return MyListTile(
                  title: "MyListTile title",
                  subtitle: "MyListTile subtitle",
                  onTap: () async {
                    await MyAlertDialog.showAlertIfCondition(
                      context: context,
                      condition: true,
                      title: "On tap title",
                      content: "MyAlertDialog content",
                    );
                  },
                  leading: MyIconButton(
                    icon: Icon(Icons.abc),
                    onTap: () async {
                      await MyAlertDialog.showAlertIfCondition(
                        context: context,
                        condition: true,
                        title: "Leading title",
                        content: "MyAlertDialog content",
                      );
                    },
                  ),
                  trailing: MyIconButton(
                    icon: Icon(Icons.abc_outlined),
                    onTap: () async {
                      await MyAlertDialog.showAlertIfCondition(
                        context: context,
                        condition: true,
                        title: "Trailing title",
                        content: "MyAlertDialog content",
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((widget) => widget is MyListTile),
          findsOneWidget);
      await tester
          .tap(find.byWidgetPredicate((widget) => widget is MyListTile));
      await tester.pumpAndSettle();
      expect(find.text('On tap title'), findsOneWidget);
      await tester.tap(find.byKey(Key("alert_ok")));
      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.abc),
          findsOneWidget);
      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.abc));
      await tester.pumpAndSettle();
      expect(find.text('Leading title'), findsOneWidget);
      await tester.tap(find.byKey(Key("alert_ok")));
      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.abc_outlined),
          findsOneWidget);
      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.abc_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Trailing title'), findsOneWidget);
      await tester.tap(find.byKey(Key("alert_ok")));
      await tester.pumpAndSettle();
    });

    testWidgets('MyModal renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return Column(
                  children: [
                    MyButton(
                      text: "Open modal 1",
                      onPressed: () async {
                        await MyModal.show(
                          context: context,
                          title: "Modal title1",
                          titleWidget: Text("Modal title2"),
                          child: Text("Modal text"),
                          heightFactor: 0.85,
                          doneCancelMode: false,
                          onDone: () {},
                        );
                      },
                    ),
                    MyButton(
                      text: "Open modal 2",
                      onPressed: () async {
                        await MyModal.show(
                          context: context,
                          child: MyModal(
                            doneCancelMode: true,
                            heightFactor: 0.85,
                            onDone: () {},
                            child: Text("Modal text"),
                          ),
                          heightFactor: 0.85,
                          doneCancelMode: true,
                          onDone: () {},
                        );
                      },
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("OPEN MODAL 1"));
      await tester.pumpAndSettle();
      expect(find.text('Modal text'), findsOneWidget);
      expect(find.text('Modal title1'), findsOneWidget);
      expect(find.text('Modal title2'), findsOneWidget);
      var modalDragBar = find.byKey(Key("modal_drag_bar"));
      const offset = Offset(0, 550);
      await tester.fling(
        modalDragBar,
        offset,
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('Modal text'), findsNothing);

      await tester.tap(find.text("OPEN MODAL 2"));
      await tester.pumpAndSettle();
      expect(find.text('Modal text'), findsOneWidget);
      await tester.tap(find.byKey(Key("modal_cancel")));
      await tester.pumpAndSettle();
      expect(find.text('Modal text'), findsNothing);
    });

    testWidgets('MyTextField renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: MyTextField(
                maxLength: 40,
                maxLines: 2,
                hintText: "hintText",
                controller: TextEditingController(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      var myTextField =
          find.byWidgetPredicate((widget) => widget is MyTextField);
      await tester.enterText(myTextField, 'Hello, World!');
      await tester.pumpAndSettle();
      expect(find.text('Hello, World!'), findsOneWidget);
    });

    testWidgets('PillBox has a text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: PillBox(
                child: Text(
                  "Hello",
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('PollEventTile renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
                create: (context) => MockFirebaseUser()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: Builder(builder: (context) {
                  return PollEventTile(
                    pollEvent: PollEventModel(
                      pollEventName: "test poll event model",
                      organizerUid: "test organizer uid",
                      pollEventDesc: "test poll event description",
                      deadline: "2024-05-15 19:30:00",
                      public: true,
                      canInvite: true,
                      dates: {},
                      locations: [],
                      isClosed: false,
                    ),
                    descTop: "PollEventTile desc top",
                    descMiddle: "PollEventTile desc middle",
                    onTap: () async {
                      await MyAlertDialog.showAlertIfCondition(
                        context: context,
                        condition: true,
                        title: "On tap title",
                        content: "MyAlertDialog content",
                      );
                    },
                    trailing: MyIconButton(
                      icon: Icon(Icons.abc_outlined),
                      onTap: () async {
                        await MyAlertDialog.showAlertIfCondition(
                          context: context,
                          condition: true,
                          title: "Trailing title",
                          content: "MyAlertDialog content",
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("PollEventTile desc top"), findsOneWidget);
      expect(find.text("PollEventTile desc middle"), findsOneWidget);

      expect(find.byWidgetPredicate((widget) => widget is PollEventTile),
          findsOneWidget);
      await tester
          .tap(find.byWidgetPredicate((widget) => widget is PollEventTile));
      await tester.pumpAndSettle();
      expect(find.text('On tap title'), findsOneWidget);
      await tester.tap(find.byKey(Key("alert_ok")));
      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.abc_outlined),
          findsOneWidget);
      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.abc_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Trailing title'), findsOneWidget);
      await tester.tap(find.byKey(Key("alert_ok")));
      await tester.pumpAndSettle();
    });

    testWidgets('ProfilePic renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
                create: (context) => MockFirebaseUser()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: Builder(builder: (context) {
                  return Column(
                    children: [
                      ProfilePicFromUid(userUid: "userUid"),
                      ProfilePicFromData(
                        userData: UserModel(
                          uid: 'test organizer uid',
                          email: 'test email',
                          username: 'test username',
                          name: 'test name',
                          surname: 'test surname',
                          profilePic:
                              'https://images.ygoprodeck.com/images/cards_cropped/83152482.jpg',
                        ),
                        showUserName: true,
                        notShowDialog: true,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((widget) => widget is CircleAvatar),
          findsNWidgets(2));

      await tester.tap(find
          .byWidgetPredicate((widget) => widget is ProfilePicFromData)
          .first);
      await tester.pumpAndSettle();
      expect(find.text('test name\ntest surname'), findsOneWidget);
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();
      expect(find.text('test name\ntest surname'), findsNothing);

      await tester.tap(find
          .byWidgetPredicate((widget) => widget is ProfilePicFromData)
          .last);
      await tester.pumpAndSettle();
      expect(find.text('test name\ntest surname'), findsNothing);
    });

    testWidgets('ProfilePicsStack renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
                create: (context) => MockFirebaseUser()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    ProfilePicsStack(
                      radius: 40,
                      offset: 30,
                      uids: ["1", "2", "3"],
                    ),
                    ProfilePicsStack(
                      radius: 40,
                      offset: 30,
                      uids: [],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((widget) => widget is CircleAvatar),
          findsNWidgets(4));
    });

    testWidgets('ResponsiveWrapper has a text', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ResponsiveWrapper(
                child: Text("Hello"),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('SearchTile renders correctly', (tester) async {
      TextEditingController controller = TextEditingController();
      controller.text = "";
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: SearchTile(
                controller: controller,
                focusNode: FocusNode(),
                hintText: "hintText",
                onChanged: (value) async {},
                emptySearch: () {
                  controller.text = "";
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      var searchTile = find.byWidgetPredicate((widget) => widget is SearchTile);
      await tester.enterText(searchTile, 'Hello, World!');
      await tester.pumpAndSettle();
      expect(find.text('Hello, World!'), findsOneWidget);
      await tester
          .tap(find.byWidgetPredicate((widget) => widget is IconButton));
      await tester.pumpAndSettle();
      expect(find.text('Hello, World!'), findsNothing);
    });

    testWidgets('showSnackBar renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return MyButton(
                  text: "Show the snackbar",
                  onPressed: () async {
                    showSnackBar(context, "This is a snackbar");
                  },
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byWidgetPredicate((widget) => widget is MyButton));
      await tester.pump(Duration(seconds: 1));
      expect(find.text('This is a snackbar'), findsOneWidget);
    });

    testWidgets('TabbarSwitcher renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
          ],
          child: MaterialApp(
            home: TabbarSwitcher(
              labels: ["tab1", "tab2"],
              stickyHeight: 100,
              alwaysShowTitle: true,
              appBarTitle: "App bar title",
              listSticky: Text("Sticky title"),
              upRightActions: [],
              tabbars: [
                Text("tab1 body"),
                Text("tab2 body"),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('App bar title'), findsOneWidget);
      expect(find.text('Sticky title'), findsOneWidget);
      expect(find.text('tab1 body'), findsOneWidget);

      await tester.tap(find.text("tab2"));
      await tester.pumpAndSettle();
      expect(find.text('tab2 body'), findsOneWidget);
    });

    testWidgets('TabbarSwitcher no sticky renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
          ],
          child: MaterialApp(
            home: TabbarSwitcher(
              labels: ["tab1", "tab2"],
              stickyHeight: 0,
              alwaysShowTitle: true,
              appBarTitle: "App bar title",
              upRightActions: [],
              tabbars: [
                Text("tab1 body"),
                Text("tab2 body"),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('App bar title'), findsOneWidget);
      expect(find.text('Sticky title'), findsNothing);
      expect(find.text('tab1 body'), findsOneWidget);

      await tester.tap(find.text("tab2"));
      await tester.pumpAndSettle();
      expect(find.text('tab2 body'), findsOneWidget);
    });

    testWidgets('TabletNavigationRail renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseUser>(
              create: (context) => MockFirebaseUser(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
          ],
          child: MaterialApp(
            home: TabletNavigationRail(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is Icon),
        findsAtLeastNWidgets(4),
      );
    });

    testWidgets('UserTile renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
                create: (context) => MockFirebaseUser()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: Builder(builder: (context) {
                  return Column(
                    children: [
                      UserTileFromUid(
                        userUid: "userUid",
                        trailing: MyIconButton(
                          icon: Icon(Icons.abc_outlined),
                          onTap: () async {
                            await MyAlertDialog.showAlertIfCondition(
                              context: context,
                              condition: true,
                              title: "Trailing title",
                              content: "MyAlertDialog content",
                            );
                          },
                        ),
                      ),
                      UserTileFromData(
                        userData: MockFirebaseUser.testUserModel,
                        trailing: MyIconButton(
                          icon: Icon(Icons.abc_outlined),
                          onTap: () async {
                            await MyAlertDialog.showAlertIfCondition(
                              context: context,
                              condition: true,
                              title: "Trailing title",
                              content: "MyAlertDialog content",
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((widget) => widget is MyListTile),
          findsNWidgets(2));
      await tester
          .tap(find.byWidgetPredicate((widget) => widget is MyListTile).first);
      await tester.pumpAndSettle();
      expect(find.text('test name\ntest surname'), findsOneWidget);
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.abc_outlined),
          findsNWidgets(2));
      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.abc_outlined)
          .first);
      await tester.pumpAndSettle();
      expect(find.text('Trailing title'), findsOneWidget);
      await tester.tap(find.byKey(Key("alert_ok")));
      await tester.pumpAndSettle();
    });
  });
}
