import 'package:flutter/material.dart';

class Availability {
  static const int empty = -1;
  static const int not = 0;
  static const int iff = 1;
  static const int yes = 2;

  static Map<int, IconData> icons = {
    -1: Icons.help,
    0: Icons.unpublished,
    1: Icons.offline_pin,
    2: Icons.check_circle,
  };

  static Color color(context, int availability) {
    switch (availability) {
      case empty:
        return Theme.of(context).unselectedWidgetColor;
      case not:
        return Theme.of(context).colorScheme.error;
      case iff:
        return Colors.yellow;
      case yes:
        return Colors.lightGreen;
      default:
        return Theme.of(context).focusColor;
    }
  }
}
