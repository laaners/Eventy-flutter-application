import 'package:flutter/material.dart';

class Palette {
  // Colors, hex to decimal: 342C44 -> 34|2C|44 -> 52|44|68
  // or directly use Color(0x00342c44), but vs code won't show preview this way
  static const blackColor = Color.fromRGBO(1, 1, 1, 1);
  static const whiteColor = Colors.white;
  static const greyColor = Color.fromRGBO(128, 128, 128, 1);

  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const lightBGColor = Color.fromRGBO(236, 220, 252, 1);
  static const darkBGColor = Color.fromRGBO(1, 1, 1, 1);
  //static const lightBGColor = Color(0x00ecdcfc);

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: darkBGColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
    primaryColor: lightBGColor,
    textTheme: const TextTheme(
      bodySmall: TextStyle(color: Colors.white30),
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white70),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(
        color: Colors.orange,
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.amber,
      ),
    ),
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: lightBGColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
    primaryColor: darkBGColor,
    textTheme: const TextTheme(
      bodySmall: TextStyle(color: Colors.black38),
      bodyMedium: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black87),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(
        color: Colors.orange,
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.amber,
      ),
    ),
  );
}
