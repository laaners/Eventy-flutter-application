import 'package:flutter/foundation.dart';

class EventCollection {
  final String eventName;
  final String organizerUid;
  final String eventDesc;
  final bool public;
  final bool canInvite;
  final Map<String, dynamic> date;
  final Map<String, dynamic> location;
  EventCollection({
    required this.eventName,
    required this.organizerUid,
    required this.eventDesc,
    required this.public,
    required this.canInvite,
    required this.date,
    required this.location,
  });

  static const collectionName = "event";

  EventCollection copyWith({
    String? eventName,
    String? organizerUid,
    String? eventDesc,
    String? deadline,
    bool? public,
    bool? canInvite,
    Map<String, dynamic>? date,
    Map<String, dynamic>? location,
  }) {
    return EventCollection(
      eventName: eventName ?? this.eventName,
      organizerUid: organizerUid ?? this.organizerUid,
      eventDesc: eventDesc ?? this.eventDesc,
      public: public ?? this.public,
      canInvite: canInvite ?? this.canInvite,
      date: date ?? this.date,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'eventName': eventName,
      'organizerUid': organizerUid,
      'eventDesc': eventDesc,
      'public': public,
      'canInvite': canInvite,
      'date': date,
      'location': location,
    };
  }

  factory EventCollection.fromMap(Map<String, dynamic> map) {
    return EventCollection(
      eventName: map['eventName'] as String,
      organizerUid: map['organizerUid'] as String,
      eventDesc: map['eventDesc'] as String,
      public: map['public'] as bool,
      canInvite: map['canInvite'] as bool,
      date: Map<String, dynamic>.from(map['date'] as Map<String, dynamic>),
      location:
          Map<String, dynamic>.from(map['location'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'EventCollection(eventName: $eventName, organizerUid: $organizerUid, eventDesc: $eventDesc, public: $public, canInvite: $canInvite, date: $date, location: $location)';
  }

  @override
  bool operator ==(covariant EventCollection other) {
    if (identical(this, other)) return true;

    return other.eventName == eventName &&
        other.organizerUid == organizerUid &&
        other.eventDesc == eventDesc &&
        other.public == public &&
        other.canInvite == canInvite &&
        mapEquals(other.date, date) &&
        mapEquals(other.location, location);
  }

  @override
  int get hashCode {
    return eventName.hashCode ^
        organizerUid.hashCode ^
        eventDesc.hashCode ^
        public.hashCode ^
        canInvite.hashCode ^
        date.hashCode ^
        location.hashCode;
  }
}
