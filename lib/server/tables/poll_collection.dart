import 'package:dima_app/server/date_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class PollCollection {
  final String pollName;
  final String organizerUid;
  final String pollDesc;
  final String deadline;
  final bool public;
  final bool canInvite;
  final Map<String, dynamic> dates;
  final List<Map<String, dynamic>> locations;
  PollCollection({
    required this.pollName,
    required this.organizerUid,
    required this.pollDesc,
    required this.deadline,
    required this.dates,
    required this.locations,
    required this.public,
    required this.canInvite,
  });

  // PK = pollName_organizerUid
  static const collectionName = "poll";

  static Map<String, dynamic> datesToUtc(Map<String, dynamic> dates) {
    Map<String, dynamic> utcDates = {};
    dates.forEach((day, slots) {
      slots.forEach((slot, _) {
        var startDateString = "${day.split(" ")[0]} ${slot.split("-")[0]}:00";
        var endDateString = "${day.split(" ")[0]} ${slot.split("-")[1]}:00";
        var startDateUtc = DateFormatter.string2DateTime(
            DateFormatter.toUtcString(startDateString));
        var endDateUtc = DateFormatter.string2DateTime(
            DateFormatter.toUtcString(endDateString));
        String utcDay = DateFormat("yyyy-MM-dd").format(startDateUtc);
        var startUtc = DateFormat("HH:mm").format(startDateUtc);
        var endUtc = DateFormat("HH:mm").format(endDateUtc);
        if (!utcDates.containsKey(utcDay)) {
          utcDates[utcDay] = [];
        }
        utcDates[utcDay].add({
          "start": startUtc,
          "end": endUtc,
        });
      });
    });
    return utcDates;
  }

  static Map<String, dynamic> datesToLocal(Map<String, dynamic> dates) {
    Map<String, dynamic> localDates = {};
    dates.forEach((day, slots) {
      slots.forEach((slot) {
        var startDateString = "${day.split(" ")[0]} ${slot["start"]}:00";
        var endDateString = "${day.split(" ")[0]} ${slot["end"]}:00";
        var startDateLocal = DateFormatter.string2DateTime(
            DateFormatter.toLocalString(startDateString));
        var endDateLocal = DateFormatter.string2DateTime(
            DateFormatter.toLocalString(endDateString));
        String localDay = DateFormat("yyyy-MM-dd").format(startDateLocal);
        var startLocal = DateFormat("HH:mm").format(startDateLocal);
        var endLocal = DateFormat("HH:mm").format(endDateLocal);
        if (!localDates.containsKey(localDay)) {
          localDates[localDay] = [];
        }
        localDates[localDay].add({
          "start": startLocal,
          "end": endLocal,
        });
      });
    });
    return localDates;
  }

  PollCollection copyWith({
    String? pollName,
    String? organizerUid,
    String? pollDesc,
    String? deadline,
    Map<String, dynamic>? dates,
    List<Map<String, dynamic>>? locations,
    bool? public,
    bool? canInvite,
  }) {
    return PollCollection(
      pollName: pollName ?? this.pollName,
      organizerUid: organizerUid ?? this.organizerUid,
      pollDesc: pollDesc ?? this.pollDesc,
      deadline: deadline ?? this.deadline,
      dates: dates ?? this.dates,
      locations: locations ?? this.locations,
      public: public ?? this.public,
      canInvite: canInvite ?? this.canInvite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollName': pollName,
      'organizerUid': organizerUid,
      'pollDesc': pollDesc,
      'deadline': deadline,
      'dates': dates,
      'locations': locations,
      'public': public,
      'canInvite': canInvite,
    };
  }

  factory PollCollection.fromMap(Map<String, dynamic> map) {
    return PollCollection(
      pollName: map['pollName'] as String,
      organizerUid: map['organizerUid'] as String,
      pollDesc: map['pollDesc'] as String,
      deadline: map['deadline'] as String,
      dates: Map<String, dynamic>.from((map['dates'] as Map<String, dynamic>)),
      locations: List<Map<String, dynamic>>.from(
        (map['locations'] as List<Map<String, dynamic>>)
            .map<Map<String, dynamic>>((x) => x),
      ),
      public: map['public'] as bool,
      canInvite: map['canInvite'] as bool,
    );
  }

  @override
  String toString() {
    return 'PollCollection(pollName: $pollName, organizerUid: $organizerUid, pollDesc: $pollDesc, deadline: $deadline, dates: $dates, locations: $locations, public: $public, canInvite: $canInvite)';
  }

  @override
  bool operator ==(covariant PollCollection other) {
    if (identical(this, other)) return true;

    return other.pollName == pollName &&
        other.organizerUid == organizerUid &&
        other.pollDesc == pollDesc &&
        other.deadline == deadline &&
        mapEquals(other.dates, dates) &&
        listEquals(other.locations, locations) &&
        other.public == public &&
        other.canInvite == canInvite;
  }

  @override
  int get hashCode {
    return pollName.hashCode ^
        organizerUid.hashCode ^
        pollDesc.hashCode ^
        deadline.hashCode ^
        dates.hashCode ^
        locations.hashCode ^
        public.hashCode ^
        canInvite.hashCode;
  }
}
