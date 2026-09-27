import 'package:map/map/domain/entities/map_location.dart';

class MapMarkerData {
  final String id;
  final MapLocation location;
  final String? type;

  const MapMarkerData({required this.id, required this.location, this.type});
}
