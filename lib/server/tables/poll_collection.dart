import 'package:flutter/foundation.dart';

class PollCollection {
  final String pollName;
  final String organizerUid;
  final String pollDesc;
  final String deadline;
  final bool public;
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
  });

  // PK = pollName_organizerUid
  static const collectionName = "poll";

  PollCollection copyWith({
    String? pollName,
    String? organizerUid,
    String? pollDesc,
    String? deadline,
    Map<String, dynamic>? dates,
    List<Map<String, dynamic>>? locations,
    bool? public,
  }) {
    return PollCollection(
      pollName: pollName ?? this.pollName,
      organizerUid: organizerUid ?? this.organizerUid,
      pollDesc: pollDesc ?? this.pollDesc,
      deadline: deadline ?? this.deadline,
      dates: dates ?? this.dates,
      locations: locations ?? this.locations,
      public: public ?? this.public,
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
    );
  }

  @override
  String toString() {
    return 'PollCollection(pollName: $pollName, organizerUid: $organizerUid, pollDesc: $pollDesc, deadline: $deadline, dates: $dates, locations: $locations, public: $public)';
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
        other.public == public;
  }

  @override
  int get hashCode {
    return pollName.hashCode ^
        organizerUid.hashCode ^
        pollDesc.hashCode ^
        deadline.hashCode ^
        dates.hashCode ^
        locations.hashCode ^
        public.hashCode;
  }
}
