import 'package:flutter/foundation.dart';

import 'availability.dart';
import 'poll_event_invite_collection.dart';

class VoteLocationCollection {
  final String pollId;
  final String locationName;
  final Map<String, dynamic> votes;
  VoteLocationCollection({
    required this.pollId,
    required this.locationName,
    required this.votes,
  });
  static const collectionName = "vote_location";

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

  VoteLocationCollection copyWith({
    String? pollId,
    String? locationName,
    Map<String, dynamic>? votes,
  }) {
    return VoteLocationCollection(
      pollId: pollId ?? this.pollId,
      locationName: locationName ?? this.locationName,
      votes: votes ?? this.votes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollId': pollId,
      'locationName': locationName,
      'votes': votes,
    };
  }

  factory VoteLocationCollection.fromMap(Map<String, dynamic> map) {
    return VoteLocationCollection(
      pollId: map['pollId'] as String,
      locationName: map['locationName'] as String,
      votes: Map<String, dynamic>.from((map['votes'] as Map<String, dynamic>)),
    );
  }

  @override
  String toString() =>
      'VoteLocationCollection(pollId: $pollId, locationName: $locationName, votes: $votes)';

  @override
  bool operator ==(covariant VoteLocationCollection other) {
    if (identical(this, other)) return true;

    return other.pollId == pollId &&
        other.locationName == locationName &&
        mapEquals(other.votes, votes);
  }

  @override
  int get hashCode => pollId.hashCode ^ locationName.hashCode ^ votes.hashCode;
}
