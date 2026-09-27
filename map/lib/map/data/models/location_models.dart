class LocationModels {
  double lat;
  double lng;

  LocationModels({required this.lat, required this.lng});

  factory LocationModels.fromMap(Map<String, dynamic> map) {
    return LocationModels(lat: map['lat'], lng: map['lng']);
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng};
  }
}
