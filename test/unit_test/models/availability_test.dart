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

    testWidgets('color should return the correct colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return Column(
                  children: [
                    Container(
                        color: Availability.color(context, Availability.empty)),
                    Container(
                        color: Availability.color(context, Availability.not)),
                    Container(
                        color: Availability.color(context, Availability.iff)),
                    Container(
                        color: Availability.color(context, Availability.yes)),
                    Container(color: Availability.color(context, -2)),
                  ],
                );
              }),
            ),
          ),
        ),
      );
      expect(Availability.color("none", Availability.iff), Colors.yellow);
      expect(Availability.color("none", Availability.yes), Colors.lightGreen);
    });

    test('description should return the correct description', () {
      expect(Availability.description(Availability.empty), "Pending");
      expect(Availability.description(Availability.not), "Not attending");
      expect(Availability.description(Availability.iff), "If need be");
      expect(Availability.description(Availability.yes), "Attending");
      expect(Availability.description(-2), "All");
    });
  });
}
