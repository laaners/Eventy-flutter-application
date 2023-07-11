import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('VoteDateModel', () {
    final testVote = VoteDateModel(
      pollId: 'poll1',
      date: '2023-05-15',
      start: '08:00',
      end: '10:00',
      votes: {
        'user1': 1,
        'user2': 2,
        'user3': 0,
        'user4': -1,
      },
    );

    final testInvites = [
      PollEventInviteModel(pollEventId: "pollEventId0", inviteeId: "user1"),
      PollEventInviteModel(pollEventId: "pollEventId0", inviteeId: "user2"),
      PollEventInviteModel(pollEventId: "pollEventId0", inviteeId: "user3"),
      PollEventInviteModel(pollEventId: "pollEventId0", inviteeId: "user4"),
    ];

    test('dateToUtc and dateToLocal methods should work correctly', () {
      Map<String, String> testDateUtc =
          VoteDateModel.dateToUtc("2023-11-07", "08:00", "10:00");
      Map<String, String> testDateLocal = VoteDateModel.dateToLocal(
        testDateUtc["date"],
        testDateUtc["start"],
        testDateUtc["end"],
      );
      expect(testDateLocal, {
        "date": "2023-11-07",
        "start": "08:00",
        "end": "10:00",
      });
    });

    test('copyWith should copy the VoteDateModel', () {
      final copiedVote = testVote.copyWith(
        pollId: 'poll2',
      );

      expect(copiedVote.pollId, 'poll2');
      expect(copiedVote.date, '2023-05-15');
      expect(copiedVote.start, '08:00');
      expect(copiedVote.end, '10:00');
      expect(
          mapEquals(copiedVote.votes, {
            'user1': 1,
            'user2': 2,
            'user3': 0,
            'user4': -1,
          }),
          true);
    });

    test('toMap should return a map with correct data', () {
      final voteMap = testVote.toMap();

      expect(voteMap, {
        'pollId': 'poll1',
        'date': '2023-05-15',
        'start': '08:00',
        'end': '10:00',
        'votes': {
          'user1': 1,
          'user2': 2,
          'user3': 0,
          'user4': -1,
        },
      });
    });

    test('fromMap should return a VoteDateModel with correct data', () {
      final voteMap = {
        'pollId': 'poll1',
        'date': '2023-05-15',
        'start': '08:00',
        'end': '10:00',
        'votes': {
          'user1': 1,
          'user2': 2,
          'user3': 0,
          'user4': -1,
        },
      };

      final voteFromMap = VoteDateModel.fromMap(voteMap);

      expect(voteFromMap, testVote);
    });

    test('getVotesKind should correctly return votes of specific kind', () {
      final positiveVotes = VoteDateModel.getVotesKind(
        voteDate: testVote,
        kind: Availability.yes,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(positiveVotes, {'organizer': 2, 'user2': 2});

      final emptyVotes = VoteDateModel.getVotesKind(
        voteDate: testVote,
        kind: Availability.empty,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(emptyVotes, {'user4': -1});

      final notVotes = VoteDateModel.getVotesKind(
        voteDate: testVote,
        kind: Availability.not,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(notVotes, {'user3': 0});

      final iffVotes = VoteDateModel.getVotesKind(
        voteDate: testVote,
        kind: Availability.iff,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(iffVotes, {'user1': 1});

      // null voteDate
      final nullPositiveVotes = VoteDateModel.getVotesKind(
        voteDate: null,
        kind: Availability.yes,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(nullPositiveVotes, {'organizer': 2});

      final nullEmptyVotes = VoteDateModel.getVotesKind(
        voteDate: null,
        kind: Availability.empty,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(nullEmptyVotes, {
        'user1': -1,
        'user2': -1,
        'user3': -1,
        'user4': -1,
      });

      // corner case
      final cornerCase = VoteDateModel.getVotesKind(
        voteDate: testVote,
        kind: Availability.empty,
        invites: [
          PollEventInviteModel(
              pollEventId: "pollEventId0", inviteeId: "user_corner")
        ],
        organizerUid: 'organizer',
      );

      expect(cornerCase, {
        'user4': -1,
        'user_corner': -1,
      });
    });

    test('getPositiveVotes should correctly return positive votes', () {
      final positiveVotes = testVote.getPositiveVotes();
      expect(positiveVotes, {'user1': 1, 'user2': 2});
    });

    test('toString should work correctly', () {
      expect(testVote.toString(),
          'VoteDateCollection(pollId: poll1, date: 2023-05-15, start: 08:00, end: 10:00, votes: {user1: 1, user2: 2, user3: 0, user4: -1})');
    });

    test('Equality and hashCode should work correctly', () {
      final copy = testVote.copyWith();
      expect(copy, testVote);
      expect(copy.copyWith(votes: {}) == testVote, false);
      expect(copy.hashCode, testVote.hashCode);
    });
  });
}
