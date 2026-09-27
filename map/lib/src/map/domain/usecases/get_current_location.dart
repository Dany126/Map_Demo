import 'package:dartz/dartz.dart';
import '../../../core/errors/failures/failure.dart';
import '../../../core/utils/usecase.dart';
import '../entities/map_location.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocation extends UsecaseWithoutParams<MapLocation> {
  final LocationRepository repo;

  GetCurrentLocation({required this.repo});

  @override
  Future<Either<Failure, MapLocation>> call() {
    return repo.getCurrentLocation();
  }
}
