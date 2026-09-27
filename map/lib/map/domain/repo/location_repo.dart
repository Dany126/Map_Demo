import 'package:dartz/dartz.dart';
import 'package:map/core/errors/failures/failure.dart';
import 'package:map/map/data/models/location_models.dart';

abstract class LocationRepo {
  Future<Either<Failure, void>> checkPermission();
  Future<Either<Failure, LocationModels>> getCurrentLocation();
  Future<Either<Failure, LocationModels>> getLiveLocation();
}
