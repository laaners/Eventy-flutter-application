// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Location {
  final String name;
  final String site;
  final double lat;
  final double lon;
  final String icon;
  Location(
    this.name,
    this.site,
    this.lat,
    this.lon,
    this.icon,
  );

  @override
  String toString() {
    return 'Location(name: $name, site: $site, lat: $lat, lon: $lon, icon: $icon)';
  }

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'site': site,
      'lat': lat,
      'lon': lon,
      'icon': icon,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      map['name'] as String,
      map['site'] as String,
      map['lat'] as double,
      map['lon'] as double,
      map['icon'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Location.fromJson(String source) =>
      Location.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant Location other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.site == site &&
        other.lat == lat &&
        other.lon == lon &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        site.hashCode ^
        lat.hashCode ^
        lon.hashCode ^
        icon.hashCode;
  }
}
