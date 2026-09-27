import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map/map.dart';
import 'package:map/src/core/errors/failures/failure.dart';
import 'package:map/src/map/domain/repositories/location_repository.dart';
import 'package:map/src/map/domain/repositories/route_repository.dart';

class FakeTestLocationRepository implements LocationRepository {
  final MapLocation location;
  FakeTestLocationRepository(this.location);

  @override
  Future<Either<Failure, MapLocation>> getCurrentLocation() async {
    return Right(location);
  }

  @override
  Stream<MapLocation> getLocationStream() {
    return Stream.value(location);
  }
}

class FakeTestRouteRepository implements RouteRepository {
  @override
  Future<Either<Failure, MapRoute>> getRoute({
    required MapLocation start,
    required MapLocation destination,
  }) async {
    return const Right(
      MapRoute(
        points: [
          MapLocation(lat: 30.0, lng: 31.0),
          MapLocation(lat: 30.1, lng: 31.1),
        ],
        distanceInMeters: 500,
        durationInSeconds: 60,
      ),
    );
  }
}

void main() {
  testWidgets('MapView renders correctly with default configuration', (
    WidgetTester tester,
  ) async {
    const testLocation = MapLocation(lat: 30.0444, lng: 31.2357);
    final locationRepo = FakeTestLocationRepository(testLocation);
    final routeRepo = FakeTestRouteRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapView(
            locationRepository: locationRepo,
            routeRepository: routeRepo,
            markers: const [
              MapMarkerData(
                id: 'm1',
                type: 'restaurant',
                location: MapLocation(lat: 30.05, lng: 31.24),
              ),
            ],
          ),
        ),
      ),
    );

    // Initial pump triggers Bloc loading
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MapView), findsOneWidget);
  });
}
