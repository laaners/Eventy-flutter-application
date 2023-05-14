import 'package:flutter/material.dart';

class Availability {
  static int empty = -1;
  static int not = 0;
  static int iff = 1;
  static int yes = 2;

  static Map<int, IconData> icons = {
    -1: Icons.help,
    0: Icons.unpublished,
    1: Icons.offline_pin,
    2: Icons.check_circle,
  };
}
