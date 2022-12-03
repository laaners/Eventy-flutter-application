import 'package:dima_app/screens/event_detail.dart';
import 'package:dima_app/screens/events.dart';
import 'package:dima_app/screens/home.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/widgets/my_tab_bar.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:dima_app/provider_samples.dart';

void main() async {
/*   WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(
  //  options: Platform.isLinux
  //      ? DefaultFirebaseOptions.linux
  //      : DefaultFirebaseOptions.currentPlatform,
  //);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 */

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

        // Below a theme changer example------------------------------------------------------------------------------------------------
        // DARK/LIGHT THEME
        ChangeNotifierProvider(create: (context) => ThemeSwitch())
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeSwitch extends ChangeNotifier {
  ThemeData _themeData = Palette.lightModeAppTheme;

  // getter
  ThemeData get themeData => _themeData;

  void changeTheme() {
    _themeData = _themeData == Palette.lightModeAppTheme
        ? Palette.darkModeAppTheme
        : Palette.lightModeAppTheme;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit Tutorial',
      initialRoute: '/',
      routes: {
        '/event_detail': (context) => const EventDetailScreen(),
      },
      theme: Provider.of<ThemeSwitch>(context).themeData,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Home"),
            actions: [
              TextButton(
                onPressed: () {
                  Provider.of<ThemeSwitch>(context, listen: false)
                      .changeTheme();
                },
                child: const Text(
                  "DARK/LIGHT MODE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: const TabBarView(
            children: [
              HomeScreen(),
              EventsScreen(),
            ],
          ),
          bottomNavigationBar: const MyTabBar(),
        ),
      ),
    );
  }
}
