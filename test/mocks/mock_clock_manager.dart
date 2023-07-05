import 'package:dima_app/services/clock_manager.dart';
import 'package:mockito/mockito.dart';

class MockClockManager extends Mock implements ClockManager {
  @override
  bool get clockMode => true;

  void toggleClock(bool is24Hour) {}
}
