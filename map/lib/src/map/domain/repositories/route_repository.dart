import 'package:dartz/dartz.dart';

import '../../../core/errors/failures/failure.dart';
import '../entities/map_location.dart';
import '../entities/map_route.dart';

abstract class RouteRepository {
  Future<Either<Failure, MapRoute>> getRoute({
    required MapLocation start,
    required MapLocation destination,
  });
}
