// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dima_app/models/event_location_preview.dart';
import 'package:flutter/foundation.dart';

class EventLocationModel {
  final String site;
  final double lat;
  final double lon;
  final List<EventLocationPreview> events;
  EventLocationModel({
    required this.site,
    required this.lat,
    required this.lon,
    required this.events,
  });

  static const collectionName = "event_location";

  EventLocationModel copyWith({
    String? site,
    double? lat,
    double? lon,
    List<EventLocationPreview>? events,
  }) {
    return EventLocationModel(
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
      'events': events.map((x) => x.toMap()).toList(),
    };
  }

  factory EventLocationModel.fromMap(Map<String, dynamic> map) {
    return EventLocationModel(
      site: map['site'] as String,
      lat: map['lat'] as double,
      lon: map['lon'] as double,
      events: List<EventLocationPreview>.from(
        (map['events'] as List<Map<String, dynamic>>).map<EventLocationPreview>(
          (x) => EventLocationPreview.fromMap(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory EventLocationModel.fromJson(String source) =>
      EventLocationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EventLocationCollection(site: $site, lat: $lat, lon: $lon, events: $events)';
  }

  @override
  bool operator ==(covariant EventLocationModel other) {
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
