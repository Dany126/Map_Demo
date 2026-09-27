import 'package:flutter_test/flutter_test.dart';
import 'package:map/map.dart';
import 'package:map/src/map/data/models/route_model.dart';

void main() {
  group('RouteModel', () {
    test('should parse valid OSRM json correctly', () {
      final json = {
        'routes': [
          {
            'distance': 1500.0,
            'duration': 300.0,
            'geometry': {
              'coordinates': [
                [31.2357, 30.0444],
                [31.2400, 30.0480],
              ],
            },
          },
        ],
      };

      final model = RouteModel.fromJson(json);

      expect(model, isA<MapRoute>());
      expect(model.points.length, 2);
      expect(model.points[0].lat, 30.0444);
      expect(model.points[0].lng, 31.2357);
      expect(model.points[1].lat, 30.0480);
      expect(model.points[1].lng, 31.2400);
      expect(model.distanceInMeters, 1500.0);
      expect(model.durationInSeconds, 300.0);
      expect(model.distanceInKilometers, 1.5);
      expect(model.durationInMinutes, 5);
    });

    test('should throw an exception when routes array is empty', () {
      final json = {'routes': <dynamic>[]};

      expect(() => RouteModel.fromJson(json), throwsException);
    });
  });
}
