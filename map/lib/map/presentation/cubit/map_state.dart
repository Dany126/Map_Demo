import '../../domain/entities/map_marker_data.dart';

sealed class MapState {
  const MapState();
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapMarkerSelected extends MapState {
  final MapMarkerData marker;

  const MapMarkerSelected(this.marker);
}
