import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/screens/events.dart';
import 'package:dima_app/screens/home.dart';
import 'package:dima_app/screens/login.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_methods.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:dima_app/provider_samples.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          create: (context) => FirebaseUser(_auth, _firestore),
        ),
        ChangeNotifierProvider(
          create: (context) => FirebaseFollow(_firestore),
        ),
        ChangeNotifierProvider(
          create: (context) => FirebasePoll(_firestore),
        ),

        // DARK/LIGHT THEME
        ChangeNotifierProvider(create: (context) => ThemeSwitch())
      ],
      child: const MyApp(),
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventy',
      theme: Provider.of<ThemeSwitch>(context).themeData,
      home: Consumer<FirebaseUser>(
        builder: (context, value, child) {
          return value.user != null ? const MainScreen() : const LogInScreen();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventy',
      theme: Provider.of<ThemeSwitch>(context).themeData,
      home: CupertinoTabScaffold(
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
          activeColor: Provider.of<ThemeSwitch>(context).themeData.primaryColor,
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
          switch (index) {
            case 0:
              return CupertinoTabView(
                navigatorKey: firstTabNavKey,
                builder: (context) =>
                    const CupertinoPageScaffold(child: HomeScreen()),
              );
            case 1:
              return CupertinoTabView(
                navigatorKey: secondTabNavKey,
                builder: (context) =>
                    const CupertinoPageScaffold(child: EventsScreen()),
              );
            case 2:
              return CupertinoTabView(
                navigatorKey: fourthTabNavKey,
                builder: (context) =>
                    const CupertinoPageScaffold(child: ProfileScreen()),
              );
            default:
              return const CupertinoTabView();
          }
        },
      ),
    );
  }
}
