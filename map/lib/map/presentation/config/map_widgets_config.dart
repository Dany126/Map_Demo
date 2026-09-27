import 'package:flutter/material.dart';

import '../../domain/entities/map_marker_data.dart';
import '../../domain/entities/map_route.dart';
import '../widgets/map_control_actions.dart';

typedef UserMarkerBuilder = Widget Function(
  BuildContext context,
  MapMarkerData marker,
);

typedef MarkerBuilder = Widget Function(
  BuildContext context,
  MapMarkerData marker,
  bool isSelected,
);

typedef ControlsBuilder = Widget Function(
  BuildContext context,
  MapControlActions actions,
);

typedef RouteInfoBuilder = Widget Function(
  BuildContext context,
  MapRoute route,
);

typedef LoadingBuilder = Widget Function(BuildContext context);

typedef ErrorBuilder = Widget Function(BuildContext context, String message);

typedef MarkerBottomSheetBuilder = Widget Function(
  BuildContext context,
  MapMarkerData marker,
  VoidCallback onShowRoute,
);

class MapWidgetsConfig {
  final bool showUserMarker;
  final bool showMarkers;
  final bool showRoute;
  final bool showControls;
  final bool showRouteInfo;
  final bool showRouteLoading;
  final bool showLocationLoading;
  final bool showLocationError;
  final bool showMarkerBottomSheet;

  final UserMarkerBuilder? userMarkerBuilder;

  final MarkerBuilder? markerBuilder;

  final ControlsBuilder? controlsBuilder;

  final RouteInfoBuilder? routeInfoBuilder;

  final LoadingBuilder? routeLoadingBuilder;

  final LoadingBuilder? locationLoadingBuilder;

  final ErrorBuilder? locationErrorBuilder;

  final MarkerBottomSheetBuilder? markerBottomSheetBuilder;

  const MapWidgetsConfig({
    this.showUserMarker = true,
    this.showMarkers = true,
    this.showRoute = true,
    this.showControls = true,
    this.showRouteInfo = true,
    this.showRouteLoading = true,
    this.showLocationLoading = true,
    this.showLocationError = true,
    this.showMarkerBottomSheet = true,
    this.userMarkerBuilder,
    this.markerBuilder,
    this.controlsBuilder,
    this.routeInfoBuilder,
    this.routeLoadingBuilder,
    this.locationLoadingBuilder,
    this.locationErrorBuilder,
    this.markerBottomSheetBuilder,
  });
}
