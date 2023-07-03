import 'package:dima_app/models/poll_event_notification.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pollEventNotification = PollEventNotification(
    pollEventId: "test poll event id",
    body: 'test poll event notification body',
    organizerUid: 'test poll event notification organizer uid',
    title: 'test poll event notification title',
    timestamp: '2023-06-30 12:26:09', // in utc
    isRead: false,
  );

  group('PollEventNotificationModel', () {
    test('copyWith method should work correctly', () {
      final copy = pollEventNotification.copyWith(body: 'another body');
      expect(copy.body, 'another body');
      expect(copy.pollEventId, 'test poll event id');
    });

    test('toMap and fromMap should work correctly', () {
      final map = pollEventNotification.toMap();
      final fromMap = PollEventNotification.fromMap(map);
      expect(
        fromMap,
        pollEventNotification.copyWith(
          timestamp: DateFormatter.toLocalString(
            pollEventNotification.timestamp,
          ),
        ),
      );
    });

    test('toString should work correctly', () {
      expect(pollEventNotification.toString(),
          'PollEventNotification(pollEventId: test poll event id, organizerUid: test poll event notification organizer uid, title: test poll event notification title, body: test poll event notification body, isRead: false, timestamp: 2023-06-30 12:26:09)');
    });

    test('Equality and hashCode should work correctly', () {
      final copy = pollEventNotification.copyWith();
      expect(copy, pollEventNotification);
      expect(copy.hashCode, pollEventNotification.hashCode);
    });
  });
}
