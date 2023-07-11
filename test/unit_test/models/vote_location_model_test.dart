import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('VoteLocationModel', () {
    final testVote = VoteLocationModel(
      pollId: 'poll1',
      locationName: "test location name",
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

    test('copyWith should copy the VoteLocationModel', () {
      final copiedVote = testVote.copyWith(pollId: 'poll2');

      expect(copiedVote.pollId, 'poll2');
      expect(copiedVote.locationName, 'test location name');
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
        'locationName': 'test location name',
        'votes': {
          'user1': 1,
          'user2': 2,
          'user3': 0,
          'user4': -1,
        },
      });
    });

    test('fromMap should return a VoteLocationModel with correct data', () {
      final voteMap = {
        'pollId': 'poll1',
        'locationName': 'test location name',
        'votes': {
          'user1': 1,
          'user2': 2,
          'user3': 0,
          'user4': -1,
        },
      };

      final voteFromMap = VoteLocationModel.fromMap(voteMap);

      expect(voteFromMap, testVote);
    });

    test('getVotesKind should correctly return votes of specific kind', () {
      final positiveVotes = VoteLocationModel.getVotesKind(
        voteLocation: testVote,
        kind: Availability.yes,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(positiveVotes, {'organizer': 2, 'user2': 2});

      final emptyVotes = VoteLocationModel.getVotesKind(
        voteLocation: testVote,
        kind: Availability.empty,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(emptyVotes, {'user4': -1});

      final notVotes = VoteLocationModel.getVotesKind(
        voteLocation: testVote,
        kind: Availability.not,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(notVotes, {'user3': 0});

      final iffVotes = VoteLocationModel.getVotesKind(
        voteLocation: testVote,
        kind: Availability.iff,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(iffVotes, {'user1': 1});

      // null voteDate
      final nullPositiveVotes = VoteLocationModel.getVotesKind(
        voteLocation: null,
        kind: Availability.yes,
        invites: testInvites,
        organizerUid: 'organizer',
      );

      expect(nullPositiveVotes, {'organizer': 2});

      final nullEmptyVotes = VoteLocationModel.getVotesKind(
        voteLocation: null,
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
      final cornerCase = VoteLocationModel.getVotesKind(
        voteLocation: testVote,
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
          'VoteLocationCollection(pollId: poll1, locationName: test location name, votes: {user1: 1, user2: 2, user3: 0, user4: -1})');
    });

    test('Equality and hashCode should work correctly', () {
      final copy = testVote.copyWith();
      expect(copy, testVote);
      expect(copy.copyWith(votes: {}) == testVote, false);
      expect(copy.hashCode, testVote.hashCode);
    });
  });
}
