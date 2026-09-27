import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map/map/domain/repositories/location_repo.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/errors/failures/failure.dart';
import '../../domain/entities/map_location.dart';
import '../models/location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<Either<Failure, MapLocation>> getCurrentLocation() async {
    try {
      final permission = await _checkPermission();

      if (!permission) {
        return Left(ErrorHandler.handle('Location permission denied'));
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return Right(
        LocationModel.fromCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Stream<MapLocation> getLocationStream() async* {
    final permission = await _checkPermission();

    if (!permission) {
      throw Exception('Location permission denied');
    }

    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    await for (final position in stream) {
      yield LocationModel.fromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
  }

  Future<bool> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
