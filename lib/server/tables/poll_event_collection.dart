import 'package:dima_app/server/date_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class PollEventCollection {
  final String pollEventName;
  final String organizerUid;
  final String pollEventDesc;
  final String deadline;
  final bool public;
  final bool canInvite;
  final Map<String, dynamic> dates;
  final List<Map<String, dynamic>> locations;
  final bool isClosed;
  PollEventCollection({
    required this.pollEventName,
    required this.organizerUid,
    required this.pollEventDesc,
    required this.deadline,
    required this.dates,
    required this.locations,
    required this.public,
    required this.canInvite,
    required this.isClosed,
  });

  // PK = pollName_organizerUid
  static const collectionName = "poll_event";

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

  PollEventCollection copyWith({
    String? pollEventName,
    String? organizerUid,
    String? pollEventDesc,
    String? deadline,
    Map<String, dynamic>? dates,
    List<Map<String, dynamic>>? locations,
    bool? public,
    bool? canInvite,
    bool? isClosed,
  }) {
    return PollEventCollection(
      pollEventName: pollEventName ?? this.pollEventName,
      organizerUid: organizerUid ?? this.organizerUid,
      pollEventDesc: pollEventDesc ?? this.pollEventDesc,
      deadline: deadline ?? this.deadline,
      dates: dates ?? this.dates,
      locations: locations ?? this.locations,
      public: public ?? this.public,
      canInvite: canInvite ?? this.canInvite,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollEventName': pollEventName,
      'organizerUid': organizerUid,
      'pollEventDesc': pollEventDesc,
      'deadline': deadline,
      'dates': dates,
      'locations': locations,
      'public': public,
      'canInvite': canInvite,
      'isClosed': isClosed,
    };
  }

  factory PollEventCollection.fromMap(Map<String, dynamic> map) {
    return PollEventCollection(
      pollEventName: map['pollEventName'] as String,
      organizerUid: map['organizerUid'] as String,
      pollEventDesc: map['pollEventDesc'] as String,
      deadline: map['deadline'] as String,
      dates: Map<String, dynamic>.from((map['dates'] as Map<String, dynamic>)),
      locations: List<Map<String, dynamic>>.from(
        (map['locations'] as List<Map<String, dynamic>>)
            .map<Map<String, dynamic>>((x) => x),
      ),
      public: map['public'] as bool,
      canInvite: map['canInvite'] as bool,
      isClosed: map['isClosed'] as bool,
    );
  }

  @override
  String toString() {
    return 'PollCollection(pollEventName: $pollEventName, organizerUid: $organizerUid, pollEventDesc: $pollEventDesc, deadline: $deadline, dates: $dates, locations: $locations, public: $public, canInvite: $canInvite, isClosed: $isClosed)';
  }

  @override
  bool operator ==(covariant PollEventCollection other) {
    if (identical(this, other)) return true;

    return other.pollEventName == pollEventName &&
        other.organizerUid == organizerUid &&
        other.pollEventDesc == pollEventDesc &&
        other.deadline == deadline &&
        mapEquals(other.dates, dates) &&
        listEquals(other.locations, locations) &&
        other.public == public &&
        other.canInvite == canInvite &&
        other.isClosed == isClosed;
  }

  @override
  int get hashCode {
    return pollEventName.hashCode ^
        organizerUid.hashCode ^
        pollEventDesc.hashCode ^
        deadline.hashCode ^
        dates.hashCode ^
        locations.hashCode ^
        public.hashCode ^
        canInvite.hashCode ^
        isClosed.hashCode;
  }
}
