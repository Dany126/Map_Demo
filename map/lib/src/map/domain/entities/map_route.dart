import 'map_location.dart';

class MapRoute {
  final List<MapLocation> points;
  final double distanceInMeters;
  final double durationInSeconds;

  const MapRoute({
    required this.points,
    required this.distanceInMeters,
    required this.durationInSeconds,
  });

  double get distanceInKilometers {
    return distanceInMeters / 1000;
  }

  int get durationInMinutes {
    return (durationInSeconds / 60).round();
  }
}
