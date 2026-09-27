import 'map_camera_config.dart';
import 'map_interaction_config.dart';
import 'map_route_config.dart';
import 'map_tile_config.dart';
import 'map_widgets_config.dart';

class MapViewConfig {
  final MapCameraConfig camera;
  final MapTileConfig tiles;
  final MapRouteConfig route;
  final MapInteractionConfig interactions;
  final MapWidgetsConfig widgets;

  const MapViewConfig({
    this.camera = const MapCameraConfig(),
    this.tiles = const MapTileConfig(),
    this.route = const MapRouteConfig(),
    this.interactions = const MapInteractionConfig(),
    this.widgets = const MapWidgetsConfig(),
  });
}
