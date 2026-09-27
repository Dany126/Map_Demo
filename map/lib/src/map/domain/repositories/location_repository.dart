import 'package:dartz/dartz.dart';

import '../../../core/errors/failures/failure.dart';
import '../entities/map_location.dart';

abstract class LocationRepository {
  Future<Either<Failure, MapLocation>> getCurrentLocation();

  Stream<MapLocation> getLocationStream();
}
