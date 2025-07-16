class GeofenceZone {
  final double lat;
  final double lng;

  GeofenceZone({required this.lat, required this.lng});

  factory GeofenceZone.fromJson(Map<String, dynamic> json) {
    return GeofenceZone(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
