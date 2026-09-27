import '../../domain/entities/map_location.dart';

class LocationModel extends MapLocation {
  const LocationModel({required super.lat, required super.lng});

  factory LocationModel.fromCoordinates({
    required double latitude,
    required double longitude,
  }) {
    return LocationModel(lat: latitude, lng: longitude);
  }
}
