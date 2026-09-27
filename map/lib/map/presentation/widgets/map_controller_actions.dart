import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class MapControllerActions {
  final void Function(LatLng position, {double? zoom}) moveTo;

  final void Function(List<LatLng> points, {double padding}) fitBounds;

  final VoidCallback zoomIn;

  final VoidCallback zoomOut;

  final VoidCallback locateMe;

  final VoidCallback fitAll;

  final VoidCallback fitRoute;

  const MapControllerActions({
    required this.moveTo,
    required this.fitBounds,
    required this.zoomIn,
    required this.zoomOut,
    required this.locateMe,
    required this.fitAll,
    required this.fitRoute,
  });
}
