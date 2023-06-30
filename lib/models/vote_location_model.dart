import 'package:collection/collection.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:flutter/foundation.dart';
import 'availability.dart';

/// VoteLocationModel class for storing poll event votes for a specific location.
class VoteLocationModel {
  final String pollId;
  final String locationName;
  final Map<String, dynamic> votes;

  /// VoteLocationModel constructor
  VoteLocationModel({
    required this.pollId,
    required this.locationName,
    required this.votes,
  });
  static const collectionName = "vote_location";

  /// This method gets the votes of a specific kind, e.g. Availability.yes or Availability.no .
  static Map<String, dynamic> getVotesKind({
    required VoteLocationModel? voteLocation,
    required int kind,
    required List<PollEventInviteModel> invites,
    required String organizerUid,
  }) {
    Map<String, dynamic> votesKind = {};
    if (voteLocation == null) {
      switch (kind) {
        case Availability.yes:
          return {organizerUid: Availability.yes};
        case Availability.empty:
          for (var invite in invites) {
            if (invite.inviteeId != organizerUid) {
              votesKind[invite.inviteeId] = Availability.empty;
            }
          }
          return votesKind;
        default:
          return {};
      }
    }
    voteLocation.votes.forEach((key, value) {
      if (value == kind) {
        votesKind[key] = value;
      }
    });
    if (kind == Availability.empty) {
      for (var invite in invites) {
        if (!voteLocation.votes.containsKey(invite.inviteeId) &&
            invite.inviteeId != organizerUid) {
          votesKind[invite.inviteeId] = Availability.empty;
        }
      }
    }
    if (kind == Availability.yes) {
      votesKind[organizerUid] = Availability.yes;
    }
    return votesKind;
  }

  /// This method gets the positive votes, i.e. Availability.yes or Availability.iff .
  Map<String, dynamic> getPositiveVotes() {
    Map<String, dynamic> votesKind = {};
    votes.forEach((key, value) {
      if (value == Availability.yes || value == Availability.iff) {
        votesKind[key] = value;
      }
    });
    return votesKind;
  }

  /// This method performs a deep copy of a VoteLocationModel object.
  VoteLocationModel copyWith({
    String? pollId,
    String? locationName,
    Map<String, dynamic>? votes,
  }) {
    return VoteLocationModel(
      pollId: pollId ?? this.pollId,
      locationName: locationName ?? this.locationName,
      votes: votes ?? this.votes,
    );
  }

  /// This method converts a VoteLocationModel object to a Map<String, dynamic>.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollId': pollId,
      'locationName': locationName,
      'votes': votes,
    };
  }

  /// This method converts a Map<String, dynamic> to a VoteLocationModel object.
  factory VoteLocationModel.fromMap(Map<String, dynamic> map) {
    return VoteLocationModel(
      pollId: map['pollId'] as String,
      locationName: map['locationName'] as String,
      votes: Map<String, dynamic>.from((map['votes'] as Map<String, dynamic>)),
    );
  }

  /// This method converts a VoteLocationModel object to a JSON object.
  @override
  String toString() =>
      'VoteLocationCollection(pollId: $pollId, locationName: $locationName, votes: $votes)';

  /// This method overrides the == operator for the VoteLocationModel class, so that two VoteLocationModel objects are equal if they have the same pollId, locationName and votes.
  @override
  bool operator ==(covariant VoteLocationModel other) {
    if (identical(this, other)) return true;

    return other.pollId == pollId &&
        other.locationName == locationName &&
        (mapEquals(other.votes, votes) ||
            DeepCollectionEquality().equals(other.votes, votes));
  }

  /// This method creates a hash code for a VoteLocationModel object.
  @override
  int get hashCode => pollId.hashCode ^ locationName.hashCode ^ votes.hashCode;
}
