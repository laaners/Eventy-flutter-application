class Location {
  final String name;
  final String description;
  final String site;
  final double lat;
  final double lon;
  Location(this.name, this.description, this.site, this.lat, this.lon);

  @override
  String toString() {
    return 'Location(name: $name, description: $description, site: $site, lat: $lat, lon: $lon)';
  }
}
