import 'package:dima_app/constants/preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Preferences', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
    });

    test('getBool method should return the correct value', () {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('key', true);
        expect(Preferences.getBool('key'), true);
      });
    });

    test('getBool method should return the default value', () {
      expect(Preferences.getBool('non_existent_key'), false);
    });

    test('setBool method should set the correct value', () async {
      await Preferences.setBool('key', false);
      SharedPreferences.getInstance().then((prefs) {
        expect(prefs.getBool('key'), false);
      });
    });
  });
}
