class Location {
  final String name;
  final String site;
  final double lat;
  final double lon;
  final String icon;
  Location(this.name, this.site, this.lat, this.lon, this.icon);

  @override
  String toString() {
    return 'Location(name: $name, site: $site, lat: $lat, lon: $lon, icon: $icon)';
  }
}
