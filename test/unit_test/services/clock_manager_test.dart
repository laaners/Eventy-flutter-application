// Import necessary dependencies and packages
import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCallbackFunction extends Mock {
  call();
}

void main() {
  group('ClockManager', () {
    late ClockManager clockManager;
    final notifyListenerCallback = MockCallbackFunction();

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
      clockManager = ClockManager()..addListener(notifyListenerCallback);
    });

    test('get method should return the correct value', () async {
      expect(clockManager.clockMode, Preferences.getBool('is24Hour'));
    });

    test(
        'toogleClock method should set the correct value and notify the listeners',
        () {
      clockManager.toggleClock(true);
      expect(Preferences.getBool('is24Hour'), true);
      clockManager.toggleClock(false);
      expect(Preferences.getBool('is24Hour'), false);
      // verify notifyListener called twice
      verify(notifyListenerCallback()).called(2);
    });
  });
}
