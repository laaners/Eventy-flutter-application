// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EventLocationPreview {
  final String eventId;
  final String eventName;
  final String locationName;
  final String locationBanner;
  final String date;
  final String start;
  final String end;
  final bool public;
  final bool invited;

  EventLocationPreview(
    this.eventId,
    this.eventName,
    this.locationName,
    this.locationBanner,
    this.date,
    this.start,
    this.end,
    this.public,
    this.invited,
  );

  EventLocationPreview copyWith({
    String? eventId,
    String? eventName,
    String? locationName,
    String? locationBanner,
    String? date,
    String? start,
    String? end,
    bool? public,
    bool? invited,
  }) {
    return EventLocationPreview(
      eventId ?? this.eventId,
      eventName ?? this.eventName,
      locationName ?? this.locationName,
      locationBanner ?? this.locationBanner,
      date ?? this.date,
      start ?? this.start,
      end ?? this.end,
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
      'date': date,
      'start': start,
      'end': end,
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
      map['date'] as String,
      map['start'] as String,
      map['end'] as String,
      map['public'] as bool,
      map['invited'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory EventLocationPreview.fromJson(String source) =>
      EventLocationPreview.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EventLocationPreview(eventId: $eventId, eventName: $eventName, locationName: $locationName, locationBanner: $locationBanner, date: $date, start: $start, end: $end, public: $public, invited: $invited)';
  }

  @override
  bool operator ==(covariant EventLocationPreview other) {
    if (identical(this, other)) return true;

    return other.eventId == eventId &&
        other.eventName == eventName &&
        other.locationName == locationName &&
        other.locationBanner == locationBanner &&
        other.date == date &&
        other.start == start &&
        other.end == end &&
        other.public == public &&
        other.invited == invited;
  }

  @override
  int get hashCode {
    return eventId.hashCode ^
        eventName.hashCode ^
        locationName.hashCode ^
        locationBanner.hashCode ^
        date.hashCode ^
        start.hashCode ^
        end.hashCode ^
        public.hashCode ^
        invited.hashCode;
  }
}
