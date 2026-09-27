import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map/map.dart';
import 'package:map/src/core/errors/failures/failure.dart';
import 'package:map/src/core/errors/failures/server_failure.dart';
import 'package:map/src/map/domain/repositories/location_repository.dart';
import 'package:map/src/map/domain/usecases/get_current_location.dart';
import 'package:map/src/map/domain/usecases/watch_location.dart';
import 'package:map/src/map/presentation/cubit/location_cubit.dart';
import 'package:map/src/map/presentation/cubit/location_state.dart';

class FakeLocationRepository implements LocationRepository {
  final Either<Failure, MapLocation> result;
  final Stream<MapLocation> stream;

  FakeLocationRepository({
    required this.result,
    Stream<MapLocation>? stream,
  }) : stream = stream ?? const Stream.empty();

  @override
  Future<Either<Failure, MapLocation>> getCurrentLocation() async {
    return result;
  }

  @override
  Stream<MapLocation> getLocationStream() {
    return stream;
  }
}

void main() {
  group('LocationCubit', () {
    const testLocation = MapLocation(lat: 30.0444, lng: 31.2357);

    test('initial state should be LocationInitial', () {
      final repo = FakeLocationRepository(result: const Right(testLocation));
      final cubit = LocationCubit(
        getcurrentlocation: GetCurrentLocation(repo: repo),
        getlivelocation: GetLiveLocation(repo: repo),
      );

      expect(cubit.state, isA<LocationInitial>());
      cubit.close();
    });

    test(
      'getCurrentLocation emits LocationLoading then LocationLoaded on success',
      () async {
        final repo = FakeLocationRepository(result: const Right(testLocation));
        final cubit = LocationCubit(
          getcurrentlocation: GetCurrentLocation(repo: repo),
          getlivelocation: GetLiveLocation(repo: repo),
        );

        final expected = [
          isA<LocationLoading>(),
          isA<LocationLoaded>().having(
            (s) => s.mapLocation,
            'mapLocation',
            testLocation,
          ),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));

        await cubit.getCurrentLocation();
        cubit.close();
      },
    );

    test(
      'getCurrentLocation emits LocationLoading then LocationError on failure',
      () async {
        final repo = FakeLocationRepository(
          result: const Left(ServerFailure(message: 'Permission denied')),
        );
        final cubit = LocationCubit(
          getcurrentlocation: GetCurrentLocation(repo: repo),
          getlivelocation: GetLiveLocation(repo: repo),
        );

        final expected = [
          isA<LocationLoading>(),
          isA<LocationError>().having(
            (s) => s.message,
            'message',
            'Permission denied',
          ),
        ];

        expectLater(cubit.stream, emitsInOrder(expected));

        await cubit.getCurrentLocation();
        cubit.close();
      },
    );

    test(
      'startLocationTracking emits LocationLoaded when stream produces location',
      () async {
        final stream = Stream.value(testLocation);
        final repo = FakeLocationRepository(
          result: const Right(testLocation),
          stream: stream,
        );
        final cubit = LocationCubit(
          getcurrentlocation: GetCurrentLocation(repo: repo),
          getlivelocation: GetLiveLocation(repo: repo),
        );

        expectLater(
          cubit.stream,
          emits(
            isA<LocationLoaded>().having(
              (s) => s.mapLocation,
              'mapLocation',
              testLocation,
            ),
          ),
        );

        cubit.startLocationTracking();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        cubit.close();
      },
    );
  });
}
