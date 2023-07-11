import 'package:dima_app/services/date_methods.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormatter', () {
    test('DateFormatter methods work correctly', () {
      DateTime nowDate = DateTime(2023, 12, 20, 20, 20, 20);
      String nowString = "2023-12-20 20:20:20";
      expect(DateFormatter.dateTime2String(nowDate), nowString);
      expect(DateFormatter.string2DateTime(nowString), nowDate);
      expect(DateFormatter.toUtcDateTime(nowDate), nowDate.toUtc());
      expect(DateFormatter.toLocalDateTime(nowDate), nowDate.toLocal());
    });
  });
}
