import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSwitch extends ChangeNotifier {
  final UserCollection? _user;
  late ThemeData _themeData;

  ThemeSwitch(this._user) {
    if (_user != null) {
      _themeData = _user!.isLightMode
          ? Palette.lightModeAppTheme
          : Palette.darkModeAppTheme;
    } else {
      _themeData = Palette.lightModeAppTheme;
    }
  }

  // getter
  ThemeData get themeData => _themeData;

  void changeTheme(BuildContext context) {
    Provider.of<FirebaseUser>(context, listen: false).themeSwitch();
    /*
    _themeData = _themeData == Palette.lightModeAppTheme
        ? Palette.darkModeAppTheme
        : Palette.lightModeAppTheme;
    */
    notifyListeners();
  }
}
