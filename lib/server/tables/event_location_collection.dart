// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class EventLocationCollection {
  final String site;
  final double lat;
  final double lon;
  final List<Map<String, dynamic>> events;
  EventLocationCollection({
    required this.site,
    required this.lat,
    required this.lon,
    required this.events,
  });

  static const collectionName = "event_location";

  /*
  events: [
    {
      eventId,
      eventName,
      locationName, // given by user
      locationBanner,
      public,
      [invited] <- client side only
    }
  ]
  */

  EventLocationCollection copyWith({
    String? site,
    double? lat,
    double? lon,
    List<Map<String, dynamic>>? events,
  }) {
    return EventLocationCollection(
      site: site ?? this.site,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      events: events ?? this.events,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'site': site,
      'lat': lat,
      'lon': lon,
      'events': events,
    };
  }

  factory EventLocationCollection.fromMap(Map<String, dynamic> map) {
    return EventLocationCollection(
      site: map['site'] as String,
      lat: map['lat'] as double,
      lon: map['lon'] as double,
      events: List<Map<String, dynamic>>.from(
        (map['events'] as List<Map<String, dynamic>>)
            .map<Map<String, dynamic>>((x) => x),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory EventLocationCollection.fromJson(String source) =>
      EventLocationCollection.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EventLocationCollection(site: $site, lat: $lat, lon: $lon, events: $events)';
  }

  @override
  bool operator ==(covariant EventLocationCollection other) {
    if (identical(this, other)) return true;

    return other.site == site &&
        other.lat == lat &&
        other.lon == lon &&
        listEquals(other.events, events);
  }

  @override
  int get hashCode {
    return site.hashCode ^ lat.hashCode ^ lon.hashCode ^ events.hashCode;
  }
}
