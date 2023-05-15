// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// create documentation

/// PollEventModel class for storing poll event data.
class PollEventModel {
  final String pollEventName;
  final String organizerUid;
  final String pollEventDesc;
  final String deadline;
  final bool public;
  final bool canInvite;
  final Map<String, dynamic> dates;
  final List<Location> locations;
  final bool isClosed;

  /// PollEventModel constructor
  PollEventModel({
    required this.pollEventName,
    required this.organizerUid,
    required this.pollEventDesc,
    required this.deadline,
    required this.public,
    required this.canInvite,
    required this.dates,
    required this.locations,
    required this.isClosed,
  });

  /// Collection name for firestore
  static const collectionName = "poll_event";

  /// This method converts the dates from local to utc
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

  // This method converts the dates from utc to local
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

  /// This method converts a firestore document to a PollEventModel object
  static PollEventModel firebaseDocToObj(Map<String, dynamic> doc) {
    doc["locations"] = (doc["locations"] as List).map((e) {
      e["lat"] = e["lat"].toDouble();
      e["lon"] = e["lon"].toDouble();
      return e as Map<String, dynamic>;
    }).toList();
    // utc string
    doc["deadline"] = DateFormatter.dateTime2String(doc["deadline"].toDate());
    doc["deadline"] = DateFormatter.toLocalString(doc["deadline"]);
    doc["dates"] =
        PollEventModel.datesToLocal(doc["dates"] as Map<String, dynamic>);
    PollEventModel pollDetails = PollEventModel.fromMap(doc);
    return pollDetails;
  }

  /// This method performs a deep copy of a PollEventModel object
  PollEventModel copyWith({
    String? pollEventName,
    String? organizerUid,
    String? pollEventDesc,
    String? deadline,
    bool? public,
    bool? canInvite,
    Map<String, dynamic>? dates,
    List<Location>? locations,
    bool? isClosed,
  }) {
    return PollEventModel(
      pollEventName: pollEventName ?? this.pollEventName,
      organizerUid: organizerUid ?? this.organizerUid,
      pollEventDesc: pollEventDesc ?? this.pollEventDesc,
      deadline: deadline ?? this.deadline,
      public: public ?? this.public,
      canInvite: canInvite ?? this.canInvite,
      dates: dates ?? this.dates,
      locations: locations ?? this.locations,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  /// This method converts a PollEventModel object to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollEventName': pollEventName,
      'organizerUid': organizerUid,
      'pollEventDesc': pollEventDesc,
      'deadline': deadline,
      'public': public,
      'canInvite': canInvite,
      'dates': dates,
      'locations': locations.map((x) => x.toMap()).toList(),
      'isClosed': isClosed,
    };
  }

  /// This method converts a Map<String, dynamic> to a PollEventModel object
  factory PollEventModel.fromMap(Map<String, dynamic> map) {
    return PollEventModel(
      pollEventName: map['pollEventName'] as String,
      organizerUid: map['organizerUid'] as String,
      pollEventDesc: map['pollEventDesc'] as String,
      deadline: map['deadline'] as String,
      public: map['public'] as bool,
      canInvite: map['canInvite'] as bool,
      dates: Map<String, dynamic>.from((map['dates'] as Map<String, dynamic>)),
      locations: List<Location>.from(
        (map['locations'] as List<Map<String, dynamic>>).map<Location>(
          (x) => Location.fromMap(x),
        ),
      ),
      isClosed: map['isClosed'] as bool,
    );
  }

  /// This method converts a PollEventModel object to a json string
  String toJson() => json.encode(toMap());

  /// This method converts a json string to a PollEventModel object
  factory PollEventModel.fromJson(String source) =>
      PollEventModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// This method prints a PollEventModel object
  @override
  String toString() {
    return 'PollEventCollection(pollEventName: $pollEventName, organizerUid: $organizerUid, pollEventDesc: $pollEventDesc, deadline: $deadline, public: $public, canInvite: $canInvite, dates: $dates, locations: $locations, isClosed: $isClosed)';
  }

  /// This method compares two PollEventModel objects
  @override
  bool operator ==(covariant PollEventModel other) {
    if (identical(this, other)) return true;

    return other.pollEventName == pollEventName &&
        other.organizerUid == organizerUid &&
        other.pollEventDesc == pollEventDesc &&
        other.deadline == deadline &&
        other.public == public &&
        other.canInvite == canInvite &&
        mapEquals(other.dates, dates) &&
        listEquals(other.locations, locations) &&
        other.isClosed == isClosed;
  }

  /// This method returns the hashcode of a PollEventModel object
  @override
  int get hashCode {
    return pollEventName.hashCode ^
        organizerUid.hashCode ^
        pollEventDesc.hashCode ^
        deadline.hashCode ^
        public.hashCode ^
        canInvite.hashCode ^
        dates.hashCode ^
        locations.hashCode ^
        isClosed.hashCode;
  }
}
