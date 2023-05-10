// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EventLocationPreview {
  final String eventId;
  final String eventName;
  final String locationName;
  final String locationBanner;
  final bool public;
  final bool invited;

  EventLocationPreview(
    this.eventId,
    this.eventName,
    this.locationName,
    this.locationBanner,
    this.public,
    this.invited,
  );

  EventLocationPreview copyWith({
    String? eventId,
    String? eventName,
    String? locationName,
    String? locationBanner,
    bool? public,
    bool? invited,
  }) {
    return EventLocationPreview(
      eventId ?? this.eventId,
      eventName ?? this.eventName,
      locationName ?? this.locationName,
      locationBanner ?? this.locationBanner,
      public ?? this.public,
      invited ?? this.invited,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'eventId': eventId,
      'eventName': eventName,
      'locationName': locationName,
      'locationBanner': locationBanner,
      'public': public,
      'invited': invited,
    };
  }

  factory EventLocationPreview.fromMap(Map<String, dynamic> map) {
    return EventLocationPreview(
      map['eventId'] as String,
      map['eventName'] as String,
      map['locationName'] as String,
      map['locationBanner'] as String,
      map['public'] as bool,
      map['invited'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory EventLocationPreview.fromJson(String source) =>
      EventLocationPreview.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EventLocationPreview(eventId: $eventId, eventName: $eventName, locationName: $locationName, locationBanner: $locationBanner, public: $public, invited: $invited)';
  }

  @override
  bool operator ==(covariant EventLocationPreview other) {
    if (identical(this, other)) return true;

    return other.eventId == eventId &&
        other.eventName == eventName &&
        other.locationName == locationName &&
        other.locationBanner == locationBanner &&
        other.public == public &&
        other.invited == invited;
  }

  @override
  int get hashCode {
    return eventId.hashCode ^
        eventName.hashCode ^
        locationName.hashCode ^
        locationBanner.hashCode ^
        public.hashCode ^
        invited.hashCode;
  }
}
