import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../map/data/repositories/location_repository_impl.dart';
import '../../map/data/repositories/route_repository_impl.dart';
import '../../map/domain/repositories/location_repository.dart';
import '../../map/domain/repositories/route_repository.dart';
import '../../map/domain/usecases/get_current_location.dart';
import '../../map/domain/usecases/get_route.dart';
import '../../map/domain/usecases/watch_location.dart';
import '../../map/presentation/cubit/location_cubit.dart';
import '../../map/presentation/cubit/map_cubit.dart';
import '../../map/presentation/cubit/route_cubit.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // ===========================================================================
  // External
  // ===========================================================================

  getIt.registerLazySingleton<Dio>(() => Dio());

  // ===========================================================================
  // Location
  // ===========================================================================

  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(),
  );

  getIt.registerLazySingleton<GetCurrentLocation>(
    () => GetCurrentLocation(repo: getIt<LocationRepository>()),
  );

  getIt.registerLazySingleton<GetLiveLocation>(
    () => GetLiveLocation(repo: getIt<LocationRepository>()),
  );

  getIt.registerFactory<LocationCubit>(
    () => LocationCubit(
      getcurrentlocation: getIt<GetCurrentLocation>(),
      getlivelocation: getIt<GetLiveLocation>(),
    ),
  );

  // ===========================================================================
  // Route
  // ===========================================================================

  getIt.registerLazySingleton<RouteRepository>(
    () => RouteRepositoryImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<GetRoute>(
    () => GetRoute(repository: getIt<RouteRepository>()),
  );

  getIt.registerFactory<RouteCubit>(
    () => RouteCubit(getRoute: getIt<GetRoute>()),
  );

  // ===========================================================================
  // Map
  // ===========================================================================

  getIt.registerFactory<MapCubit>(() => MapCubit());
}
