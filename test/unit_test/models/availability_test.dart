import 'package:dima_app/models/availability.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Availability', () {
    test('Availability icons should return the correct IconData', () {
      expect(Availability.icons[Availability.empty], Icons.help);
      expect(Availability.icons[Availability.not], Icons.unpublished);
      expect(Availability.icons[Availability.iff], Icons.offline_pin);
      expect(Availability.icons[Availability.yes], Icons.check_circle);
    });
  });
}
