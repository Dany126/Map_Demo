import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map/map/presentation/config/map_camera_config.dart';
import 'package:map/map/presentation/config/map_interaction_config.dart';
import 'package:map/map/presentation/config/map_route_config.dart';
import 'package:map/map/presentation/config/map_tile_config.dart';
import 'package:map/map/presentation/config/map_view_config.dart';
import 'package:map/map/presentation/config/map_widgets_config.dart';

void main() {
  test('MapViewConfig default initialization test', () {
    const config = MapViewConfig();

    expect(config.camera.initialZoom, 16.0);
    expect(config.camera.minZoom, 3.0);
    expect(config.camera.maxZoom, 19.0);

    expect(config.tiles.show, true);
    expect(
      config.tiles.urlTemplate,
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
    expect(config.tiles.userAgentPackageName, 'com.example.map');

    expect(config.route.show, true);
    expect(config.route.color, Colors.blue);
    expect(config.route.strokeWidth, 5.0);

    expect(config.interactions.enableDrag, true);
    expect(config.interactions.enablePinchMove, true);
    expect(config.interactions.enablePinchZoom, true);
    expect(config.interactions.enableDoubleTapZoom, true);
    expect(config.interactions.enableScrollWheelZoom, true);
    expect(config.interactions.enableRotate, true);

    expect(config.widgets.showUserMarker, true);
    expect(config.widgets.showMarkers, true);
    expect(config.widgets.showRoute, true);
    expect(config.widgets.showControls, true);
    expect(config.widgets.showRouteInfo, true);
    expect(config.widgets.showRouteLoading, true);
    expect(config.widgets.showLocationLoading, true);
    expect(config.widgets.showLocationError, true);
    expect(config.widgets.showMarkerBottomSheet, true);
  });

  test('MapViewConfig custom initialization test', () {
    const customConfig = MapViewConfig(
      camera: MapCameraConfig(initialZoom: 14.0, minZoom: 5.0, maxZoom: 18.0),
      tiles: MapTileConfig(show: false),
      route: MapRouteConfig(
        show: false,
        color: Colors.green,
        strokeWidth: 4.0,
      ),
      interactions: MapInteractionConfig(
        enableDrag: false,
        enableRotate: false,
      ),
      widgets: MapWidgetsConfig(
        showUserMarker: false,
        showMarkers: false,
        showControls: false,
      ),
    );

    expect(customConfig.camera.initialZoom, 14.0);
    expect(customConfig.camera.minZoom, 5.0);
    expect(customConfig.camera.maxZoom, 18.0);
    expect(customConfig.tiles.show, false);
    expect(customConfig.route.show, false);
    expect(customConfig.route.color, Colors.green);
    expect(customConfig.route.strokeWidth, 4.0);
    expect(customConfig.interactions.enableDrag, false);
    expect(customConfig.interactions.enableRotate, false);
    expect(customConfig.widgets.showUserMarker, false);
    expect(customConfig.widgets.showMarkers, false);
    expect(customConfig.widgets.showControls, false);
  });
}
