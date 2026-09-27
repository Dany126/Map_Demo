import '../../../core/utils/usecase.dart';
import '../entities/map_location.dart';
import '../repositories/location_repository.dart';

class GetLiveLocation extends StreamUsecaseWithoutParams<MapLocation> {
  final LocationRepository repo;

  GetLiveLocation({required this.repo});

  @override
  Stream<MapLocation> call() {
    return repo.getLocationStream();
  }
}
