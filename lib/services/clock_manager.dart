import 'package:dima_app/constants/preferences.dart';
import 'package:flutter/material.dart';

// class ClockManager {
class ClockManager extends ChangeNotifier {
  bool _clockMode = Preferences.getBool('is24Hour');

  bool get clockMode => _clockMode;

  void toggleClock(bool is24Hour) {
    _clockMode = is24Hour;
    Preferences.setBool('is24Hour', _clockMode);
    notifyListeners();
  }
}
