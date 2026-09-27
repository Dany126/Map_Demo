import 'package:dartz/dartz.dart';
import 'package:map/core/errors/failures/failure.dart';
import 'package:map/core/utils/usecase.dart';
import 'package:map/map/domain/entities/map_location.dart';
import 'package:map/map/domain/repositories/location_repository.dart';

class GetCurrentLocation extends UsecaseWithoutParams<MapLocation> {
  final LocationRepository repo;
  GetCurrentLocation({required this.repo});
  @override
  Future<Either<Failure, MapLocation>> call() {
    return repo.getCurrentLocation();
  }
}
