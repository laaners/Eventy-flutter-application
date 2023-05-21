import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pollEventInviteModel = PollEventInviteModel(
    pollEventId: 'test pollEventId',
    inviteeId: 'test inviteeId',
  );

  group('PollEventInviteModel', () {
    test('copyWith method should work correctly', () {
      final copy =
          pollEventInviteModel.copyWith(pollEventId: 'another pollEventId');
      expect(copy.pollEventId, 'another pollEventId');
      expect(copy.inviteeId, 'test inviteeId');
    });

    test('toMap and fromMap should work correctly', () {
      final map = pollEventInviteModel.toMap();
      final fromMap = PollEventInviteModel.fromMap(map);
      expect(fromMap, pollEventInviteModel);
    });

    test('toString should work correctly', () {
      expect(pollEventInviteModel.toString(),
          'PollEventInviteCollection(pollEventId: test pollEventId, inviteeId: test inviteeId)');
    });

    test('Equality and hashCode should work correctly', () {
      final copy = pollEventInviteModel.copyWith();
      expect(copy, pollEventInviteModel);
      expect(copy.hashCode, pollEventInviteModel.hashCode);
    });
  });
}
