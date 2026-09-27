import 'package:map/core/utils/usecase.dart';
import 'package:map/map/domain/entities/map_location.dart';

import 'package:map/map/domain/repositories/location_repository.dart';

class GetLiveLocation extends StreamUsecaseWithoutParams<MapLocation> {
  final LocationRepository repo;
  GetLiveLocation({required this.repo});
  @override
  Stream<MapLocation> call() {
    return repo.getLocationStream();
  }
}
