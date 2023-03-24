import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:flutter/foundation.dart';

import 'availability.dart';

class VoteDateCollection {
  final String pollId;
  final String date;
  final String start;
  final String end;
  final Map<String, dynamic> votes;
  VoteDateCollection({
    required this.pollId,
    required this.date,
    required this.start,
    required this.end,
    required this.votes,
  });
  static const collectionName = "vote_date";

  Map<String, dynamic> getVotesKind(
    int kind,
    List<PollEventInviteCollection> invites,
    String organizerUid,
  ) {
    Map<String, dynamic> votesKind = {};
    votes.forEach((key, value) {
      if (value == kind) {
        votesKind[key] = value;
      }
    });
    if (kind == Availability.empty) {
      for (var invite in invites) {
        if (!votes.containsKey(invite.inviteeId) &&
            invite.inviteeId != organizerUid) {
          votesKind[invite.inviteeId] = Availability.empty;
        }
      }
    }
    return votesKind;
  }

  Map<String, dynamic> getPositiveVotes() {
    Map<String, dynamic> votesKind = {};
    votes.forEach((key, value) {
      if (value == Availability.yes || value == Availability.iff) {
        votesKind[key] = value;
      }
    });
    return votesKind;
  }

  VoteDateCollection copyWith({
    String? pollId,
    String? date,
    String? start,
    String? end,
    Map<String, dynamic>? votes,
  }) {
    return VoteDateCollection(
      pollId: pollId ?? this.pollId,
      date: date ?? this.date,
      start: start ?? this.start,
      end: end ?? this.end,
      votes: votes ?? this.votes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollId': pollId,
      'date': date,
      'start': start,
      'end': end,
      'votes': votes,
    };
  }

  factory VoteDateCollection.fromMap(Map<String, dynamic> map) {
    return VoteDateCollection(
      pollId: map['pollId'] as String,
      date: map['date'] as String,
      start: map['start'] as String,
      end: map['end'] as String,
      votes: Map<String, dynamic>.from((map['votes'] as Map<String, dynamic>)),
    );
  }

  @override
  String toString() {
    return 'VoteDateCollection(pollId: $pollId, date: $date, start: $start, end: $end, votes: $votes)';
  }

  @override
  bool operator ==(covariant VoteDateCollection other) {
    if (identical(this, other)) return true;

    return other.pollId == pollId &&
        other.date == date &&
        other.start == start &&
        other.end == end &&
        mapEquals(other.votes, votes);
  }

  @override
  int get hashCode {
    return pollId.hashCode ^
        date.hashCode ^
        start.hashCode ^
        end.hashCode ^
        votes.hashCode;
  }
}
