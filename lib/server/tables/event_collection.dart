import 'package:flutter/foundation.dart';

class EventCollection {
  final String eventName;
  final String organizerUid;
  final String eventDesc;
  final String deadline;
  final bool public;
  final Map<String, dynamic> dates;
  final Map<String, dynamic> location;
  EventCollection({
    required this.eventName,
    required this.organizerUid,
    required this.eventDesc,
    required this.deadline,
    required this.public,
    required this.dates,
    required this.location,
  });

  static const collectionName = "event";

  EventCollection copyWith({
    String? eventName,
    String? organizerUid,
    String? eventDesc,
    String? deadline,
    bool? public,
    Map<String, dynamic>? dates,
    Map<String, dynamic>? location,
  }) {
    return EventCollection(
      eventName: eventName ?? this.eventName,
      organizerUid: organizerUid ?? this.organizerUid,
      eventDesc: eventDesc ?? this.eventDesc,
      deadline: deadline ?? this.deadline,
      public: public ?? this.public,
      dates: dates ?? this.dates,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'eventName': eventName,
      'organizerUid': organizerUid,
      'eventDesc': eventDesc,
      'deadline': deadline,
      'public': public,
      'dates': dates,
      'location': location,
    };
  }

  factory EventCollection.fromMap(Map<String, dynamic> map) {
    return EventCollection(
      eventName: map['eventName'] as String,
      organizerUid: map['organizerUid'] as String,
      eventDesc: map['eventDesc'] as String,
      deadline: map['deadline'] as String,
      public: map['public'] as bool,
      dates: Map<String, dynamic>.from(map['dates'] as Map<String, dynamic>),
      location:
          Map<String, dynamic>.from(map['location'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'EventCollection(eventName: $eventName, organizerUid: $organizerUid, eventDesc: $eventDesc, deadline: $deadline, public: $public, dates: $dates, location: $location)';
  }

  @override
  bool operator ==(covariant EventCollection other) {
    if (identical(this, other)) return true;

    return other.eventName == eventName &&
        other.organizerUid == organizerUid &&
        other.eventDesc == eventDesc &&
        other.deadline == deadline &&
        other.public == public &&
        mapEquals(other.dates, dates) &&
        mapEquals(other.location, location);
  }

  @override
  int get hashCode {
    return eventName.hashCode ^
        organizerUid.hashCode ^
        eventDesc.hashCode ^
        deadline.hashCode ^
        public.hashCode ^
        dates.hashCode ^
        location.hashCode;
  }
}
