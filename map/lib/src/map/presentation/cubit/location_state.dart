import '../../domain/entities/map_location.dart';

class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final MapLocation mapLocation;
  LocationLoaded({required this.mapLocation});
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}
