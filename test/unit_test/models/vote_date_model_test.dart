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
      // PollEventInviteModel(
      //     inviteeId: 'user3', inviteeName: 'User 3', status: 1),
      PollEventInviteModel(pollEventId: "pollEventId0", inviteeId: "user1"),
      PollEventInviteModel(pollEventId: "pollEventId0", inviteeId: "user2"),
      PollEventInviteModel(pollEventId: "pollEventId0", inviteeId: "user3"),
      PollEventInviteModel(pollEventId: "pollEventId0", inviteeId: "user4"),
    ];

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
        organizerUid: 'user1',
      );

      expect(positiveVotes, {'user2': 2});

      final emptyVotes = VoteDateModel.getVotesKind(
        voteDate: testVote,
        kind: Availability.empty,
        invites: testInvites,
        organizerUid: 'user1',
      );

      expect(emptyVotes, {'user4': -1});

      final notVotes = VoteDateModel.getVotesKind(
        voteDate: testVote,
        kind: Availability.not,
        invites: testInvites,
        organizerUid: 'user1',
      );

      expect(notVotes, {'user3': 0});

      final iffVotes = VoteDateModel.getVotesKind(
        voteDate: testVote,
        kind: Availability.iff,
        invites: testInvites,
        organizerUid: 'user1',
      );

      expect(iffVotes, {'user1': 1});
    });

    test('getPositiveVotes should correctly return positive votes', () {
      final positiveVotes = testVote.getPositiveVotes();

      expect(positiveVotes, {'user1': 1, 'user2': 2});
    });
  });
}
