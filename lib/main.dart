import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dima_app/models/poll_event_notification.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/groups/groups.dart';
import 'package:dima_app/screens/home/home.dart';
import 'package:dima_app/screens/login/login.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:dima_app/screens/settings/settings.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/dynamic_links_handler.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/poll_event_methods.dart';
import 'package:dima_app/services/theme_manager.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/preferences.dart';
import 'constants/theme_constants.dart';
import 'firebase_options.dart';
import 'models/notification_model.dart';
import 'screens/notifications/notifications.dart';
import 'services/firebase_groups.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Preferences.init();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  DynamicLinksHandler dynamicLinksHandler = DynamicLinksHandler();
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  dynamicLinksHandler.setLink(initialLink);

  FirebaseNotification messaging =
      FirebaseNotification(FirebaseMessaging.instance, firestore);
  await messaging.requestPermission();
  await messaging.initHandlers();
  if (auth.currentUser != null && Preferences.getBool('isPush')) {
    await messaging.subscribeToTopic(auth.currentUser!.uid);
  } else {
    await messaging.deleteToken();
  }

  runApp(
    MultiProvider(
      providers: [
        // DARK/LIGHT THEME
        ChangeNotifierProvider<ThemeManager>(
            create: (context) => ThemeManager()),

        // CLOCK MODE, 24h/AM-PM
        ChangeNotifierProvider<ClockManager>(
            create: (context) => ClockManager()),

        // GLOBAL TAB CONTROLLER
        ChangeNotifierProvider<CupertinoTabController>(
            create: (context) => CupertinoTabController()),

        // DYNAMIC LINK
        ChangeNotifierProvider(create: (context) => DynamicLinksHandler()),

        // FIREBASE
        ChangeNotifierProvider(
            create: (context) => FirebaseUser(auth, firestore)),
        Provider(create: (context) => FirebasePollEvent(firestore)),
        Provider(create: (context) => FirebaseVote(firestore)),
        Provider(create: (context) => FirebasePollEventInvite(firestore)),
        Provider(create: (context) => FirebaseGroups(firestore)),

        // MESSAGING
        ChangeNotifierProxyProvider<FirebaseUser, FirebaseNotification>(
          create: (context) => messaging,
          update:
              (BuildContext context, value, FirebaseNotification? previous) {
            if (value.user != null) {
              previous!.subscribeToTopic(value.user!.uid);
            } else {
              previous!.deleteToken();
            }
            return previous;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Connectivity connectivity = Connectivity();

  String connectivityCheck(ConnectivityResult? result) {
    if (result == ConnectivityResult.wifi) {
      return "You are now connected to wifi";
    } else if (result == ConnectivityResult.mobile) {
      return "You are now connected to mobile data";
    } else if (result == ConnectivityResult.ethernet) {
      return "You are now connected to ethernet";
    } else if (result == ConnectivityResult.bluetooth) {
      return "You are now connected to bluetooth";
    } else if (result == ConnectivityResult.none) {
      return "No connection available";
    } else {
      return "No Connection!!";
    }
  }

  @override
  void initState() {
    super.initState();
    initLink();
  }

  void initLink() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      Provider.of<DynamicLinksHandler>(context, listen: false)
          .setLink(dynamicLinkData);
    }).onError((error) {
      // Handle errors
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
    // Disable orientation change
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    */
    return MaterialApp(
      title: 'Eventy',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      initialRoute: '/',
      home: StreamBuilder<ConnectivityResult>(
        initialData: ConnectivityResult.mobile,
        stream: Connectivity().onConnectivityChanged,
        builder: (context, snapshot) {
          connectivityCheck(snapshot.data);
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return ErrorScreen(
              customButton: MyButton(
                text: "Reload",
                onPressed: () {
                  setState(() {});
                },
              ),
            );
          }
          final connectivityResult = snapshot.data;
          if (connectivityResult == ConnectivityResult.none ||
              connectivityResult == null) {
            return ErrorScreen(
              customButton: MyButton(
                text: "Reload",
                onPressed: () {
                  setState(() {});
                },
              ),
            );
          }
          return Consumer<FirebaseUser>(
            builder: (context, value, child) {
              if (value.user != null) return const MainScreen();
              return const LogInScreen();
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  // https://stackoverflow.com/questions/52298686/flutter-pop-to-root-when-bottom-navigation-tapped
  int currentIndex = 0;

  final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> fourthTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> fifthTabNavKey = GlobalKey<NavigatorState>();

  void changeTab(int index) {
    if (index == 2) {
      Provider.of<CupertinoTabController>(context, listen: false).index =
          currentIndex;
      return;
    }
    // back home only if not switching tab
    if (currentIndex == index) {
      switch (index) {
        case 0:
          firstTabNavKey.currentState?.popUntil((r) => r.isFirst);
          break;
        case 1:
          secondTabNavKey.currentState?.popUntil((r) => r.isFirst);
          break;
        case 2:
          thirdTabNavKey.currentState?.popUntil((r) => r.isFirst);
          break;
        case 3:
          fourthTabNavKey.currentState?.popUntil((r) => r.isFirst);
          break;
        case 4:
          fifthTabNavKey.currentState?.popUntil((r) => r.isFirst);
          break;
      }
    }
    setState(() {
      currentIndex = index;
      Provider.of<CupertinoTabController>(context, listen: false).index =
          currentIndex;
    });
  }

  final Map<int, Widget> screens = {
    0: HomeScreen(),
    1: GroupsScreen(),
    3: NotificationsScreen(),
    4: SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    String curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    bool isTablet = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
            .size
            .shortestSide >=
        600;
    return Scaffold(
      // to avoid sticky keyboard when editing text
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CupertinoTabScaffold(
            controller:
                Provider.of<CupertinoTabController>(context, listen: true),
            tabBar: CupertinoTabBar(
              height: isTablet ? 0 : 50,
              onTap: changeTab,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Groups',
                ),
                // add a center docker notch floating action button to the tab bar here
                const BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Create',
                ),
                BottomNavigationBarItem(
                  icon: StreamBuilder(
                      stream: Provider.of<FirebaseNotification>(context,
                              listen: false)
                          .getUserNotificationsSnapshot(uid: curUid),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
                      ) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasError ||
                            !snapshot.hasData ||
                            !snapshot.data!.exists) {
                          return const Icon(Icons.notifications);
                        }
                        NotificationModel notificationModel =
                            NotificationModel.fromMap(
                                snapshot.data!.data() as Map<String, dynamic>);
                        List<PollEventNotification> notifications =
                            notificationModel.notifications;
                        bool anyNotRead = notifications
                            .any((notification) => !notification.isRead);
                        return Stack(
                          children: [
                            if (anyNotRead)
                              Positioned(
                                right: 0.0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            const Icon(Icons.notifications),
                          ],
                        );
                      }),
                  label: 'Notifications',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
            tabBuilder: (context, index) {
              PendingDynamicLinkData? dynamicLink =
                  Provider.of<DynamicLinksHandler>(context, listen: true)
                      .dynamicLink;
              bool pushed =
                  Provider.of<DynamicLinksHandler>(context, listen: false)
                      .pushed;
              if (dynamicLink != null && !pushed) {
                Map<String, dynamic> queryParams =
                    dynamicLink.link.queryParameters;
                String pollEventId = queryParams["pollId"];
                var curUid =
                    Provider.of<FirebaseUser>(context, listen: false).user!.uid;
                Widget newScreen = PollEventScreen(pollEventId: pollEventId);
                Provider.of<CupertinoTabController>(context, listen: false)
                    .index = 0;
                Future.delayed(const Duration(milliseconds: 100), () async {
                  setState(() {
                    currentIndex = 0;
                    Provider.of<CupertinoTabController>(context, listen: false)
                        .index = currentIndex;
                  });

                  // create invite
                  await Provider.of<FirebasePollEventInvite>(context,
                          listen: false)
                      .createPollEventInvite(
                    pollEventId: pollEventId,
                    inviteeId: curUid,
                  );

                  var ris = await firstTabNavKey.currentState?.push(
                    ScreenTransition(
                      builder: (context) => newScreen,
                    ),
                  );
                  if (ris == "delete_poll_$curUid") {
                    // ignore: use_build_context_synchronously
                    await Provider.of<FirebasePollEvent>(context, listen: false)
                        .deletePollEvent(
                      context: context,
                      pollId: pollEventId,
                    );
                  }
                });

                Provider.of<DynamicLinksHandler>(context, listen: false)
                    .pushed = true;
                // return const CupertinoPageScaffold(child: EventsScreen());
              }
              switch (index) {
                case 0:
                  return CupertinoTabView(
                    navigatorKey: firstTabNavKey,
                    builder: (context) => const HomeScreen(),
                  );
                case 1:
                  return CupertinoTabView(
                    navigatorKey: secondTabNavKey,
                    builder: (context) => const GroupsScreen(),
                  );
                case 3:
                  return CupertinoTabView(
                    navigatorKey: fourthTabNavKey,
                    builder: (context) => const NotificationsScreen(),
                  );
                case 4:
                  return CupertinoTabView(
                    navigatorKey: fifthTabNavKey,
                    builder: (context) => const SettingsScreen(),
                  );
                default:
                  return const CupertinoTabView();
              }
            },
          ),
          if (!isTablet) const CreatePollEventButton(),
        ],
      ),
    );
  }
}

class CreatePollEventButton extends StatelessWidget {
  const CreatePollEventButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            child: MaterialButton(
              key: const Key("create_poll_event"),
              onPressed: () async {
                await PollEventUserMethods.createNewPoll(context: context);
              },
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).secondaryHeaderColor,
              padding: const EdgeInsets.all(16),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
