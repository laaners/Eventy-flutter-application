import 'package:collection/collection.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'availability.dart';

/// VoteDateModel class for storing poll event votes for a specific date.
class VoteDateModel {
  final String pollId;
  final String date;
  final String start;
  final String end;
  final Map<String, dynamic> votes;

  /// VoteDateModel constructor
  VoteDateModel({
    required this.pollId,
    required this.date,
    required this.start,
    required this.end,
    required this.votes,
  });
  static const collectionName = "vote_date";

  /// This method converts the dates from local to utc
  static Map<String, String> dateToUtc(date, start, end) {
    var startDateString = "$date $start:00";
    var endDateString = "$date $end:00";
    var startDateUtc = DateFormatter.string2DateTime(
        DateFormatter.toUtcString(startDateString));
    var endDateUtc =
        DateFormatter.string2DateTime(DateFormatter.toUtcString(endDateString));
    String utcDay = DateFormat("yyyy-MM-dd").format(startDateUtc);
    var startUtc = DateFormat("HH:mm").format(startDateUtc);
    var endUtc = DateFormat("HH:mm").format(endDateUtc);
    return {"date": utcDay, "start": startUtc, "end": endUtc};
  }

  /// This method converts the dates from utc to local
  static Map<String, String> dateToLocal(date, start, end) {
    var startDateString = "$date $start:00";
    var endDateString = "$date $end:00";
    var startDateLocal = DateFormatter.string2DateTime(
        DateFormatter.toLocalString(startDateString));
    var endDateLocal = DateFormatter.string2DateTime(
        DateFormatter.toLocalString(endDateString));
    String localDay = DateFormat("yyyy-MM-dd").format(startDateLocal);
    var startLocal = DateFormat("HH:mm").format(startDateLocal);
    var endLocal = DateFormat("HH:mm").format(endDateLocal);
    return {"date": localDay, "start": startLocal, "end": endLocal};
  }

  /// This method gets the votes of a specific kind, e.g. Availability.yes or Availability.no .
  static Map<String, dynamic> getVotesKind({
    required VoteDateModel? voteDate,
    required int kind,
    required List<PollEventInviteModel> invites,
    required String organizerUid,
  }) {
    Map<String, dynamic> votesKind = {};
    if (voteDate == null) {
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
    voteDate.votes.forEach((key, value) {
      if (value == kind) {
        votesKind[key] = value;
      }
    });
    if (kind == Availability.empty) {
      for (var invite in invites) {
        if (!voteDate.votes.containsKey(invite.inviteeId) &&
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

  /// This method retrieves the votes that are positive, e.g. Availability.yes or Availability.iff .
  Map<String, dynamic> getPositiveVotes() {
    Map<String, dynamic> votesKind = {};
    votes.forEach((key, value) {
      if (value == Availability.yes || value == Availability.iff) {
        votesKind[key] = value;
      }
    });
    return votesKind;
  }

  /// VoteDateModel copyWith method for copying the object
  VoteDateModel copyWith({
    String? pollId,
    String? date,
    String? start,
    String? end,
    Map<String, dynamic>? votes,
  }) {
    return VoteDateModel(
      pollId: pollId ?? this.pollId,
      date: date ?? this.date,
      start: start ?? this.start,
      end: end ?? this.end,
      votes: votes ?? this.votes,
    );
  }

  /// VoteDateModel toMap method for converting the object to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollId': pollId,
      'date': date,
      'start': start,
      'end': end,
      'votes': votes,
    };
  }

  /// VoteDateModel fromMap method for converting a Map<String, dynamic> to a VoteDateModel object
  factory VoteDateModel.fromMap(Map<String, dynamic> map) {
    return VoteDateModel(
      pollId: map['pollId'] as String,
      date: map['date'] as String,
      start: map['start'] as String,
      end: map['end'] as String,
      votes: Map<String, dynamic>.from((map['votes'] as Map<String, dynamic>)),
    );
  }

  /// VoteDateModel toString method for printing the object
  @override
  String toString() {
    return 'VoteDateCollection(pollId: $pollId, date: $date, start: $start, end: $end, votes: $votes)';
  }

  /// VoteDateModel operator == method for comparing two VoteDateModel objects and returns true if they have the same values
  @override
  bool operator ==(covariant VoteDateModel other) {
    if (identical(this, other)) return true;

    return other.pollId == pollId &&
        other.date == date &&
        other.start == start &&
        other.end == end &&
        (mapEquals(other.votes, votes) ||
            DeepCollectionEquality().equals(other.votes, votes));
  }

  /// VoteDateModel hashCode method for hashing the object
  @override
  int get hashCode {
    return pollId.hashCode ^
        date.hashCode ^
        start.hashCode ^
        end.hashCode ^
        votes.hashCode;
  }
}
