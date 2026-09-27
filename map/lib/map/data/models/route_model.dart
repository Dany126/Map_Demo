import '../../domain/entities/map_location.dart';
import '../../domain/entities/map_route.dart';

class RouteModel extends MapRoute {
  const RouteModel({
    required super.points,
    required super.distanceInMeters,
    required super.durationInSeconds,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final routes = json['routes'] as List<dynamic>;

    if (routes.isEmpty) {
      throw Exception('No route found');
    }

    final route = routes.first as Map<String, dynamic>;

    final geometry = route['geometry'] as Map<String, dynamic>;

    final coordinates = geometry['coordinates'] as List<dynamic>;

    final points = coordinates.map<MapLocation>((coordinate) {
      final values = coordinate as List<dynamic>;

      return MapLocation(
        lat: (values[1] as num).toDouble(),
        lng: (values[0] as num).toDouble(),
      );
    }).toList();

    return RouteModel(
      points: points,
      distanceInMeters: (route['distance'] as num).toDouble(),
      durationInSeconds: (route['duration'] as num).toDouble(),
    );
  }
}
