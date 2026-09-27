import 'package:dartz/dartz.dart';

import '../../../core/errors/failures/failure.dart';
import '../entities/map_location.dart';
import '../entities/map_route.dart';
import '../repositories/route_repository.dart';

class GetRoute {
  final RouteRepository repository;

  const GetRoute({required this.repository});

  Future<Either<Failure, MapRoute>> call({
    required MapLocation start,
    required MapLocation destination,
  }) {
    return repository.getRoute(start: start, destination: destination);
  }
}
