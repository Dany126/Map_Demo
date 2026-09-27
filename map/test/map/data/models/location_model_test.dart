import 'package:flutter_test/flutter_test.dart';
import 'package:map/map.dart';
import 'package:map/src/map/data/models/location_model.dart';

void main() {
  group('LocationModel', () {
    test('should be a subclass of MapLocation', () {
      const model = LocationModel(lat: 30.0444, lng: 31.2357);
      expect(model, isA<MapLocation>());
      expect(model.lat, 30.0444);
      expect(model.lng, 31.2357);
    });

    test('fromCoordinates creates a valid LocationModel', () {
      final model = LocationModel.fromCoordinates(
        latitude: 30.0444,
        longitude: 31.2357,
      );
      expect(model.lat, 30.0444);
      expect(model.lng, 31.2357);
    });
  });
}
