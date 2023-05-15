// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Location class for storing location data
class Location {
  final String name;
  final String site;
  final double lat;
  final double lon;
  final String icon;

  /// Location constructor
  Location(
    this.name,
    this.site,
    this.lat,
    this.lon,
    this.icon,
  );

  /// Location toString method for printing a Location object
  @override
  String toString() {
    return 'Location(name: $name, site: $site, lat: $lat, lon: $lon, icon: $icon)';
  }

  /// Location copyWith method for copying a Location object
  Location copyWith({
    String? name,
    String? site,
    double? lat,
    double? lon,
    String? icon,
  }) {
    return Location(
      name ?? this.name,
      site ?? this.site,
      lat ?? this.lat,
      lon ?? this.lon,
      icon ?? this.icon,
    );
  }

  /// Location toMap method for converting a Location object to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'site': site,
      'lat': lat,
      'lon': lon,
      'icon': icon,
    };
  }

  /// Location fromMap method for converting a Map<String, dynamic> to a Location object
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      map['name'] as String,
      map['site'] as String,
      map['lat'] as double,
      map['lon'] as double,
      map['icon'] as String,
    );
  }

  /// Location toJson method for converting a Location object to a JSON string
  String toJson() => json.encode(toMap());

  /// Location fromJson method for converting a JSON string to a Location object
  factory Location.fromJson(String source) =>
      Location.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Location operator == method for comparing two Location objects
  @override
  bool operator ==(covariant Location other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.site == site &&
        other.lat == lat &&
        other.lon == lon &&
        other.icon == icon;
  }

  /// Location hashCode method for hashing a Location object
  @override
  int get hashCode {
    return name.hashCode ^
        site.hashCode ^
        lat.hashCode ^
        lon.hashCode ^
        icon.hashCode;
  }
}
