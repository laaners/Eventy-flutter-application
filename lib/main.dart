import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/screens/events.dart';
import 'package:dima_app/screens/groups.dart';
import 'package:dima_app/screens/home.dart';
import 'package:dima_app/screens/login.dart';
import 'package:dima_app/screens/signup.dart';
import 'package:dima_app/screens/profile.dart';
import 'package:dima_app/server/firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';

import 'package:provider/provider.dart';
import 'package:dima_app/provider_samples.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        Provider<FirebaseMethods>(
          create: (context) => FirebaseMethods(
            FirebaseAuth.instance,
            FirebaseFirestore.instance,
          ),
        ),

        // Firebase state management, type user
        StreamProvider(
          create: (context) =>
              Provider.of<FirebaseMethods>(context, listen: false).authState,
          initialData: null,
        ),

        // DARK/LIGHT THEME
        ChangeNotifierProvider(create: (context) => ThemeSwitch())
      ],
      child: const MyApp2(),
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
      home: const LogInScreen(),
    );
  }
}

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  State<MyApp2> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp2> {
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
              icon: Icon(Icons.groups),
              label: 'Groups',
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
                navigatorKey: thirdTabNavKey,
                builder: (context) =>
                    const CupertinoPageScaffold(child: GroupsScreen()),
              );
            case 3:
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
