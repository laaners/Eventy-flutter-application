import 'package:dima_app/models/location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final location = Location(
    'test name',
    'test site',
    1.0,
    2.0,
    'test icon',
  );

  group('Location', () {
    test('copyWith method should work correctly', () {
      final copy = location.copyWith(name: 'another name');
      expect(copy.name, 'another name');
      expect(copy.site, 'test site');
      expect(copy.lat, 1.0);
      expect(copy.lon, 2.0);
      expect(copy.icon, 'test icon');
    });

    test('toMap and fromMap should work correctly', () {
      final map = location.toMap();
      final fromMap = Location.fromMap(map);
      expect(fromMap, location);
    });

    test('toJson and fromJson should work correctly', () {
      final json = location.toJson();
      final fromJson = Location.fromJson(json);
      expect(fromJson, location);
    });

    test('toString should work correctly', () {
      expect(location.toString(),
          'Location(name: test name, site: test site, lat: 1.0, lon: 2.0, icon: test icon)');
    });

    test('Equality and hashCode should work correctly', () {
      final copy = location.copyWith();
      expect(copy, location);
      expect(copy.hashCode, location.hashCode);
    });
  });
}
