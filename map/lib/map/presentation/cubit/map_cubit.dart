import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/map_marker_data.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(const MapInitial());

  void selectMarker(MapMarkerData marker) {
    emit(
      MapMarkerSelected(marker),
    );
  }

  void clearSelectedMarker() {
    emit(
      const MapInitial(),
    );
  }
}