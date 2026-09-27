import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/watch_location.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit({
    required this.getcurrentlocation,
    required this.getlivelocation,
  }) : super(LocationInitial());

  final GetCurrentLocation getcurrentlocation;
  final GetLiveLocation getlivelocation;

  StreamSubscription? _locationSubscription;

  Future<void> getCurrentLocation() async {
    emit(LocationLoading());
    final result = await getcurrentlocation.call();
    result.fold(
      (failure) {
        emit(LocationError(failure.message));
      },
      (location) {
        emit(LocationLoaded(mapLocation: location));
      },
    );
  }

  void startLocationTracking() {
    _locationSubscription?.cancel();

    _locationSubscription = getlivelocation.call().listen(
      (location) {
        emit(LocationLoaded(mapLocation: location));
      },
      onError: (error) {
        emit(LocationError(error.toString()));
      },
    );
  }

  Future<void> stopLocationTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    return super.close();
  }
}
