import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map/core/errors/error_handler.dart';
import 'package:map/core/errors/failures/failure.dart';
import 'package:map/map/data/models/location_models.dart';
import 'package:map/map/domain/repo/location_repo.dart';

class LocationRepoImpl implements LocationRepo {
  @override
  Future<Either<Failure, void>> checkPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(ErrorHandler.handle('Permission Denied'));
        }
      }
      return Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle('Permission Denied'));
    }
  }

  @override
  Future<Either<Failure, LocationModels>> getCurrentLocation() async {
    final permission = await checkPermission();
    if (permission.isLeft()) {
      return Left(ErrorHandler.handle('Permission Denied'));
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
      return Right(
        LocationModels(lat: position.latitude, lng: position.longitude),
      );
    } catch (e) {
      return Left(ErrorHandler.handle('Permission Denied'));
    }
  }

  @override
  Future<Either<Failure, LocationModels>> getLiveLocation() async {
    final permission = await checkPermission();
    if (permission.isLeft()) {
      return Left(ErrorHandler.handle('Permission Denied'));
    }
    try {
      // Add 'await' and '.first' to get the actual Position object
      Position position = await Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          distanceFilter: 10,
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      ).first;

      return Right(
        LocationModels(lat: position.latitude, lng: position.longitude),
      );
    } catch (e) {
      return Left(ErrorHandler.handle('Permission Denied'));
    }
  }
}
