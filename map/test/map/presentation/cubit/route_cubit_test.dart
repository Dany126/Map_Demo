import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map/map.dart';
import 'package:map/src/core/errors/failures/failure.dart';
import 'package:map/src/core/errors/failures/server_failure.dart';
import 'package:map/src/map/domain/repositories/route_repository.dart';
import 'package:map/src/map/domain/usecases/get_route.dart';
import 'package:map/src/map/presentation/cubit/route_cubit.dart';
import 'package:map/src/map/presentation/cubit/route_state.dart';

class FakeSuccessRouteRepository implements RouteRepository {
  final MapRoute route;
  FakeSuccessRouteRepository(this.route);

  @override
  Future<Either<Failure, MapRoute>> getRoute({
    required MapLocation start,
    required MapLocation destination,
  }) async {
    return Right(route);
  }
}

class FakeFailureRouteRepository implements RouteRepository {
  final Failure failure;
  FakeFailureRouteRepository(this.failure);

  @override
  Future<Either<Failure, MapRoute>> getRoute({
    required MapLocation start,
    required MapLocation destination,
  }) async {
    return Left(failure);
  }
}

void main() {
  group('RouteCubit', () {
    const testRoute = MapRoute(
      points: [MapLocation(lat: 30.0, lng: 31.0)],
      distanceInMeters: 1000,
      durationInSeconds: 120,
    );

    test('initial state should be RouteInitial', () {
      final cubit = RouteCubit(
        getRoute: GetRoute(repository: FakeSuccessRouteRepository(testRoute)),
      );

      expect(cubit.state, isA<RouteInitial>());
      cubit.close();
    });

    test('loadRoute emits RouteLoading then RouteLoaded on success', () async {
      final cubit = RouteCubit(
        getRoute: GetRoute(repository: FakeSuccessRouteRepository(testRoute)),
      );

      final expectedStates = [
        isA<RouteLoading>(),
        isA<RouteLoaded>().having((s) => s.route, 'route', testRoute),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadRoute(
        start: const MapLocation(lat: 30.0, lng: 31.0),
        destination: const MapLocation(lat: 30.1, lng: 31.1),
      );

      cubit.close();
    });

    test('loadRoute emits RouteLoading then RouteError on failure', () async {
      final cubit = RouteCubit(
        getRoute: GetRoute(
          repository: FakeFailureRouteRepository(
            const ServerFailure(message: 'Network error'),
          ),
        ),
      );

      final expectedStates = [
        isA<RouteLoading>(),
        isA<RouteError>().having(
          (s) => s.message,
          'message',
          'Network error',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadRoute(
        start: const MapLocation(lat: 30.0, lng: 31.0),
        destination: const MapLocation(lat: 30.1, lng: 31.1),
      );

      cubit.close();
    });

    test('clearRoute emits RouteInitial', () {
      final cubit = RouteCubit(
        getRoute: GetRoute(repository: FakeSuccessRouteRepository(testRoute)),
      );

      cubit.clearRoute();
      expect(cubit.state, isA<RouteInitial>());
      cubit.close();
    });
  });
}
