import 'dart:io';

import 'package:flutter/material.dart';
import 'package:reddit_tutorial/features/auth/screens/login_screen.dart';
import 'package:reddit_tutorial/theme/palette.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/constants/constants.dart';
import 'firebase_options.dart';

import '0FireBaseTutorial/logintutorial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(
  //  options: Platform.isLinux
  //      ? DefaultFirebaseOptions.linux
  //      : DefaultFirebaseOptions.currentPlatform,
  //);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /*
  YES:
    [UI]<->[C]<->[R]
  NO:
    [UI]<------->[R]

  To include images add to yaml file the assets!
  */

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit Tutorial',
      // theme: ThemeData( primarySwatch: Colors.blue,),
      theme: Palette.darkModeAppTheme,
      //home: const LoginScreen(),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset(
            Constants.logoPath,
            height: 40,
          ),
          actions: [
            // Skip login
            TextButton(
              onPressed: () {},
              child: const Text(
                "Skip",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: const LoginScreenTutorial(),
      ),
    );
  }
}

// 32:54