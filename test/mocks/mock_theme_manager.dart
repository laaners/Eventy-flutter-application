import 'package:dima_app/services/theme_manager.dart';
import 'package:flutter/src/material/app.dart';
import 'package:mockito/mockito.dart';

class MockThemeManger extends Mock implements ThemeManager {
  @override
  ThemeMode get themeMode => ThemeMode.dark;

  @override
  void toggleTheme(bool isDark) {}
}
