import 'package:get_it/get_it.dart';
import 'package:map/map/data/repositories/location_repo_impl.dart';
import 'package:map/map/domain/repositories/location_repo.dart';
import 'package:map/map/domain/usecases/get_current_location.dart';
import 'package:map/map/domain/usecases/get_live_location.dart';
import 'package:map/map/presentation/cubit/location_cubit.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  // usecases
  getIt.registerLazySingleton<GetCurrentLocation>(
    () => GetCurrentLocation(repo: getIt()),
  );
  getIt.registerLazySingleton<GetLiveLocation>(
    () => GetLiveLocation(repo: getIt()),
  );
  // repository
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(),
  );

  getIt.registerLazySingleton<LocationCubit>(
    () => LocationCubit(getcurrentlocation: getIt(), getlivelocation: getIt()),
  );
}
