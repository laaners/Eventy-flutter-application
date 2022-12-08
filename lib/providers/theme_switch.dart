import 'package:dima_app/themes/palette.dart';
import 'package:flutter/material.dart';

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
