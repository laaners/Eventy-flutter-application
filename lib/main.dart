import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/providers/dynamic_links_handler.dart';
import 'package:dima_app/providers/preferences.dart';
import 'package:dima_app/screens/events.dart';
import 'package:dima_app/screens/home.dart';
import 'package:dima_app/screens/login.dart';
import 'package:dima_app/screens/poll_detail/index.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/messaging.dart';
import 'package:dima_app/themes/theme_constants.dart';
import 'package:dima_app/themes/theme_manager.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dima_app/provider_samples.dart';
import 'firebase_options.dart';

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

  await Messaging.initMessaging();

  runApp(
    MultiProvider(
      providers: [
        // Read-only
        Provider<Something>(create: (context) => const Something()),
        Provider<String>(create: (context) => "un'altra stringa"),

        // Mutable
        ChangeNotifierProvider(create: (context) => CounterProviderSample()),

        // For stream data, we made one of type int, so to call it just pass type int
        StreamProvider(
          create: (context) =>
              Stream.periodic(const Duration(seconds: 1), (x) => x).take(10),
          initialData: 1, // data to be displayed until stream emits values
        ),

        // API calls
        FutureProvider<String>(
          create: (context) => MockAPI().fetchAddress,
          initialData: "fetching address...",
        ),

        // To access values of other providers from a provider, need additional class
        ProxyProvider<Something, SecondClass>(
          update: (context, value, previous) {
            return SecondClass(value: value.stringa);
          },
        ),

        // ------------------------------------------------------------------------------------------------
        // DB, read-only provider
        /*
        Provider<FirebaseMethods>(
          create: (context) => FirebaseMethods(
            FirebaseAuth.instance,
            FirebaseFirestore.instance,
          ),
        ),
        */
        ChangeNotifierProvider(
            create: (context) => FirebaseUser(auth, firestore)),
        ChangeNotifierProxyProvider<FirebaseUser, FirebaseFollow>(
          create: (context) => FirebaseFollow(firestore, null),
          update: (BuildContext context, value, FirebaseFollow? previous) =>
              FirebaseFollow(firestore, value.user),
        ),
        ChangeNotifierProvider(create: (context) => FirebasePoll(firestore)),
        ChangeNotifierProvider(create: (context) => FirebaseEvent(firestore)),
        ChangeNotifierProvider(
            create: (context) => FirebasePollEventInvite(firestore)),
        ChangeNotifierProvider(create: (context) => FirebaseVote(firestore)),

        // DARK/LIGHT THEME
        ChangeNotifierProvider(create: (context) => ThemeManager()),

        // GLOBAL TAB CONTROLLER
        ChangeNotifierProvider<CupertinoTabController>(
          create: (context) => CupertinoTabController(),
        ),

        // DYNAMIC LINK
        ChangeNotifierProvider(create: (context) => DynamicLinksHandler()),

        // MESSAGING
        ProxyProvider<FirebaseUser, Messaging>(
          create: (context) => Messaging(null),
          update: (BuildContext context, value, Messaging? previous) =>
              Messaging(value.user),
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
  @override
  void initState() {
    initLink();
    super.initState();
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
    // init messaging mechanism
    Provider.of<Messaging>(context, listen: false);

    bool isAuthenticated =
        Provider.of<FirebaseUser>(context, listen: true).user != null;
    return MaterialApp(
      title: 'Eventy',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      initialRoute: '/',
      routes: {
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/events': (context) => const EventsScreen(),
        '/main': (context) => const MainScreen(),
      },
      home: isAuthenticated
          ? Builder(builder: (context) {
              bool hasUserData =
                  Provider.of<FirebaseUser>(context, listen: true).userData !=
                      null;
              return hasUserData
                  ? const MainScreen()
                  : FutureBuilder(
                      future: Provider.of<FirebaseUser>(context, listen: true)
                          .initUserData(),
                      builder: (
                        context,
                        snapshot,
                      ) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasError ||
                            !snapshot.hasData) {
                          return const LogInScreen();
                        }
                        return const MainScreen();
                      },
                    );
            })
          : const LogInScreen(),
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
  late final CupertinoTabController
      tabController; // = CupertinoTabController();

  final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> fourthTabNavKey = GlobalKey<NavigatorState>();

  final Map<String, Widget Function(BuildContext)> routes = {
    '/events': (context) => const EventsScreen(),
    '/main': (context) => const MainScreen(),
    '/home': (context) => const HomeScreen(),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: Provider.of<CupertinoTabController>(context, listen: true),
      tabBar: CupertinoTabBar(
        onTap: (index) {
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
            }
          }
          currentIndex = index;
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        PendingDynamicLinkData? dynamicLink =
            Provider.of<DynamicLinksHandler>(context, listen: true).dynamicLink;
        bool pushed =
            Provider.of<DynamicLinksHandler>(context, listen: false).pushed;
        if (dynamicLink != null && !pushed) {
          Map<String, dynamic> queryParams = dynamicLink.link.queryParameters;
          String pollId = queryParams["pollId"];
          switch (currentIndex) {
            case 0:
              Future.delayed(Duration.zero, () {
                firstTabNavKey.currentState?.push(
                  ScreenTransition(
                    builder: (context) => PollDetailScreen(pollId: pollId),
                  ),
                );
              });
              break;
            case 1:
              Future.delayed(Duration.zero, () {
                secondTabNavKey.currentState?.push(
                  ScreenTransition(
                    builder: (context) => PollDetailScreen(pollId: pollId),
                  ),
                );
              });
              break;
            case 2:
              Future.delayed(Duration.zero, () {
                thirdTabNavKey.currentState?.push(
                  ScreenTransition(
                    builder: (context) => PollDetailScreen(pollId: pollId),
                  ),
                );
              });
              break;
            case 3:
              Future.delayed(Duration.zero, () {
                fourthTabNavKey.currentState?.push(
                  ScreenTransition(
                    builder: (context) => PollDetailScreen(pollId: pollId),
                  ),
                );
              });
              break;
          }

          Provider.of<DynamicLinksHandler>(context, listen: false).pushed =
              true;
          // return const CupertinoPageScaffold(child: EventsScreen());
        }
        switch (index) {
          case 0:
            return CupertinoTabView(
              navigatorKey: firstTabNavKey,
              routes: routes,
              builder: (context) =>
                  const CupertinoPageScaffold(child: HomeScreen()),
            );
          case 1:
            return CupertinoTabView(
              navigatorKey: secondTabNavKey,
              routes: routes,
              builder: (context) =>
                  const CupertinoPageScaffold(child: EventsScreen()),
            );
          case 2:
            return CupertinoTabView(
              navigatorKey: thirdTabNavKey,
              routes: routes,
              builder: (context) =>
                  const CupertinoPageScaffold(child: ProfileScreen()),
            );
          default:
            return const CupertinoTabView();
        }
      },
    );
  }
}
