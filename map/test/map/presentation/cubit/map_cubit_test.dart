import 'package:flutter_test/flutter_test.dart';
import 'package:map/map.dart';
import 'package:map/src/map/presentation/cubit/map_cubit.dart';
import 'package:map/src/map/presentation/cubit/map_state.dart';

void main() {
  group('MapCubit', () {
    late MapCubit mapCubit;

    setUp(() {
      mapCubit = MapCubit();
    });

    tearDown(() {
      mapCubit.close();
    });

    test('initial state should be MapInitial', () {
      expect(mapCubit.state, isA<MapInitial>());
    });

    test('selectMarker emits MapMarkerSelected with the marker', () {
      const marker = MapMarkerData(
        id: '1',
        type: 'restaurant',
        location: MapLocation(lat: 30.0, lng: 31.0),
      );

      mapCubit.selectMarker(marker);

      expect(mapCubit.state, isA<MapMarkerSelected>());
      expect((mapCubit.state as MapMarkerSelected).marker, marker);
    });

    test('clearSelectedMarker emits MapInitial', () {
      const marker = MapMarkerData(
        id: '1',
        type: 'restaurant',
        location: MapLocation(lat: 30.0, lng: 31.0),
      );

      mapCubit.selectMarker(marker);
      mapCubit.clearSelectedMarker();

      expect(mapCubit.state, isA<MapInitial>());
    });
  });
}
