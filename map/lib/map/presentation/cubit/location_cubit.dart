import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:latlong2/latlong.dart';
import 'package:map/map/domain/usecases/get_current_location.dart';
import 'package:map/map/domain/usecases/get_live_location.dart';

import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit({
    required this.getcurrentlocation,
    required this.getlivelocation,
  }) : super(LocationInitial());
  final GetCurrentLocation getcurrentlocation;
  final GetLiveLocation getlivelocation;

  Future<void> getCurrentLocation() async {
    emit(LocationLoading());
    var result = await getcurrentlocation.call();
    result.fold(
      (failure) {
        emit(LocationError(failure.message));
      },
      (location) {
        emit(LocationLoaded(LatLng(location.lat, location.lng)));
      },
    );
  }

  Future<void> getLiveLocation() async {
    emit(LocationLoading());
    var result = await getlivelocation.call();
    result.fold(
      (failure) {
        emit(LocationError(failure.message));
      },
      (location) {
        emit(LocationLoaded(LatLng(location.lat, location.lng)));
      },
    );
  }
}
