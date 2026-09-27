import 'package:latlong2/latlong.dart';

class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final LatLng position;
  LocationLoaded(this.position);
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}
