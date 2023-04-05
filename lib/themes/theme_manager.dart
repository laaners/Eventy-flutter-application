import 'package:flutter/material.dart';
import '../providers/preferences.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode =
      Preferences.getBool('isDark') ? ThemeMode.dark : ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    Preferences.setBool('isDark', themeMode == ThemeMode.dark);
  }
}
