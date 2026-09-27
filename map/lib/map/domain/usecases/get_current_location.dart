import 'package:dartz/dartz.dart';
import 'package:map/core/errors/failures/failure.dart';
import 'package:map/core/utils/usecase.dart';
import 'package:map/map/data/models/location_models.dart';
import 'package:map/map/domain/repo/location_repo.dart';

class GetCurrentLocation extends UsecaseWithoutParams<LocationModels> {
  final LocationRepo repo;
  GetCurrentLocation({required this.repo});
  @override
  Future<Either<Failure, LocationModels>> call() {
    return repo.getCurrentLocation();
  }
}
