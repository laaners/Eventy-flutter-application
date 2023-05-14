import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'availability.dart';

class VoteDateModel {
  final String pollId;
  final String date;
  final String start;
  final String end;
  final Map<String, dynamic> votes;
  VoteDateModel({
    required this.pollId,
    required this.date,
    required this.start,
    required this.end,
    required this.votes,
  });
  static const collectionName = "vote_date";

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

  Map<String, dynamic> getVotesKind(
    int kind,
    List<PollEventInviteModel> invites,
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollId': pollId,
      'date': date,
      'start': start,
      'end': end,
      'votes': votes,
    };
  }

  factory VoteDateModel.fromMap(Map<String, dynamic> map) {
    return VoteDateModel(
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
  bool operator ==(covariant VoteDateModel other) {
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
