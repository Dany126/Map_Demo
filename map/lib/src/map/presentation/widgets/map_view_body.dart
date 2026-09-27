import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/map_location.dart';
import '../../domain/entities/map_marker_data.dart';
import '../../domain/entities/map_route.dart';
import '../config/map_view_config.dart';
import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import 'map_control_actions.dart';
import 'map_controller_actions.dart';
import 'map_controls.dart';
import 'route_info_card.dart';

class MapViewBody extends StatefulWidget {
  final List<MapMarkerData> markers;

  final MapRoute? route;

  final MapMarkerData? selectedMarker;

  final void Function(MapMarkerData marker)? onMarkerTap;

  final bool isRouteLoading;

  final VoidCallback? onClearRoute;

  final MapViewConfig config;

  /// Gives external widgets controlled access to map actions
  /// without exposing the internal MapController.
  final void Function(MapControllerActions actions)? onMapReady;

  const MapViewBody({
    super.key,
    this.markers = const [],
    this.route,
    this.selectedMarker,
    this.onMarkerTap,
    this.isRouteLoading = false,
    this.onClearRoute,
    this.config = const MapViewConfig(),
    this.onMapReady,
  });

  @override
  State<MapViewBody> createState() => _MapViewBodyState();
}

class _MapViewBodyState extends State<MapViewBody> {
  final MapController _mapController = MapController();

  MapLocation? _currentLocation;

  bool _mapReadyNotified = false;

  @override
  void didUpdateWidget(covariant MapViewBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    _handleSelectedMarkerChange(oldWidget);
    _handleRouteChange(oldWidget);
  }

  // =========================================================
  // WIDGET UPDATE HANDLERS
  // =========================================================

  void _handleSelectedMarkerChange(MapViewBody oldWidget) {
    final oldSelectedId = oldWidget.selectedMarker?.id;
    final newSelectedId = widget.selectedMarker?.id;

    if (oldSelectedId == newSelectedId) {
      return;
    }

    final marker = widget.selectedMarker;

    if (marker == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _moveToMarker(marker);
    });
  }

  void _handleRouteChange(MapViewBody oldWidget) {
    final routeWasAdded = oldWidget.route == null && widget.route != null;

    if (!routeWasAdded) {
      return;
    }

    if (!widget.config.route.show || !widget.config.widgets.showRoute) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _fitRoute();
    });
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationLoading) {
          return _buildLocationLoading(context);
        }

        if (state is LocationError) {
          return _buildLocationError(context, state.message);
        }

        if (state is LocationLoaded) {
          _currentLocation = state.mapLocation;

          return _buildLoadedMap(context, state.mapLocation);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // =========================================================
  // LOADED MAP
  // =========================================================

  Widget _buildLoadedMap(BuildContext context, MapLocation location) {
    final userPosition = LatLng(location.lat, location.lng);

    _notifyMapReady();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userPosition,
            initialZoom: widget.config.camera.initialZoom,
            minZoom: widget.config.camera.minZoom,
            maxZoom: widget.config.camera.maxZoom,
            interactionOptions: widget.config.interactions
                .toInteractionOptions(),
          ),
          children: [
            if (widget.config.tiles.show) _buildTileLayer(),

            if (widget.config.route.show &&
                widget.config.widgets.showRoute &&
                widget.route != null)
              _buildRouteLayer(),

            _buildMarkerLayer(context, userPosition, location),
          ],
        ),

        if (widget.config.widgets.showControls)
          Positioned(
            right: 16,
            bottom: 30,
            child: _buildControls(context, userPosition),
          ),

        if (widget.config.widgets.showRouteLoading && widget.isRouteLoading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: _buildRouteLoading(context),
          ),

        if (widget.config.widgets.showRouteInfo &&
            widget.route != null &&
            !widget.isRouteLoading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: _buildRouteInfo(context, widget.route!),
          ),
      ],
    );
  }

  // =========================================================
  // MAP READY
  // =========================================================

  void _notifyMapReady() {
    if (_mapReadyNotified) {
      return;
    }

    final callback = widget.onMapReady;

    if (callback == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (_mapReadyNotified) {
        return;
      }

      _mapReadyNotified = true;

      callback(
        MapControllerActions(
          moveTo: _moveToPosition,
          fitBounds: _fitBounds,
          zoomIn: _zoomIn,
          zoomOut: _zoomOut,
          locateMe: _locateCurrentLocation,
          fitAll: _fitAllCurrentMarkers,
          fitRoute: _fitRoute,
        ),
      );
    });
  }

  // =========================================================
  // TILE LAYER
  // =========================================================

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: widget.config.tiles.urlTemplate,
      userAgentPackageName: widget.config.tiles.userAgentPackageName,
    );
  }

  // =========================================================
  // MARKER LAYER
  // =========================================================

  Widget _buildMarkerLayer(
    BuildContext context,
    LatLng userPosition,
    MapLocation location,
  ) {
    final markers = <Marker>[];

    if (widget.config.widgets.showUserMarker) {
      markers.add(
        _buildUserMarker(
          context: context,
          position: userPosition,
          location: location,
        ),
      );
    }

    if (widget.config.widgets.showMarkers) {
      markers.addAll(
        widget.markers.map((marker) {
          return _buildMarker(context, marker);
        }),
      );
    }

    return MarkerLayer(markers: markers);
  }

  // =========================================================
  // USER MARKER
  // =========================================================

  Marker _buildUserMarker({
    required BuildContext context,
    required LatLng position,
    required MapLocation location,
  }) {
    final builder = widget.config.widgets.userMarkerBuilder;

    return Marker(
      point: position,
      width: 50,
      height: 50,
      child:
          builder?.call(context, location) ??
          const Icon(Icons.location_pin, size: 45, color: Colors.red),
    );
  }

  // =========================================================
  // OTHER MARKERS
  // =========================================================

  Marker _buildMarker(BuildContext context, MapMarkerData marker) {
    final isSelected = widget.selectedMarker?.id == marker.id;

    return Marker(
      point: LatLng(marker.location.lat, marker.location.lng),
      width: isSelected ? 65 : 50,
      height: isSelected ? 65 : 50,
      child: GestureDetector(
        onTap: () {
          widget.onMarkerTap?.call(marker);
        },
        child:
            widget.config.widgets.markerBuilder?.call(
              context,
              marker,
              isSelected,
            ) ??
            Icon(
              Icons.location_on,
              size: isSelected ? 50 : 40,
              color: isSelected ? Colors.orange : Colors.blue,
            ),
      ),
    );
  }

  // =========================================================
  // ROUTE LAYER
  // =========================================================

  Widget _buildRouteLayer() {
    final route = widget.route;

    if (route == null || route.points.isEmpty) {
      return const SizedBox.shrink();
    }

    return PolylineLayer(
      polylines: [
        Polyline(
          points: route.points
              .map((point) => LatLng(point.lat, point.lng))
              .toList(),
          color: widget.config.route.color,
          strokeWidth: widget.config.route.strokeWidth,
        ),
      ],
    );
  }

  // =========================================================
  // CONTROLS
  // =========================================================

  Widget _buildControls(BuildContext context, LatLng userPosition) {
    final actions = MapControlActions(
      zoomIn: _zoomIn,
      zoomOut: _zoomOut,
      locateMe: () {
        _locateMe(userPosition);
      },
      fitAll: () {
        _fitAllMarkers(userPosition);
      },
      fitRoute: _fitRoute,
      canFitRoute: widget.route != null &&
          widget.config.route.show &&
          widget.config.widgets.showRoute,
    );

    final customBuilder = widget.config.widgets.controlsBuilder;

    if (customBuilder != null) {
      return customBuilder(context, actions);
    }

    return MapControls(actions: actions);
  }

  // =========================================================
  // ZOOM IN
  // =========================================================

  void _zoomIn() {
    final camera = _mapController.camera;

    final nextZoom = (camera.zoom + 1).clamp(
      widget.config.camera.minZoom,
      widget.config.camera.maxZoom,
    );

    _mapController.move(camera.center, nextZoom.toDouble());
  }

  // =========================================================
  // ZOOM OUT
  // =========================================================

  void _zoomOut() {
    final camera = _mapController.camera;

    final nextZoom = (camera.zoom - 1).clamp(
      widget.config.camera.minZoom,
      widget.config.camera.maxZoom,
    );

    _mapController.move(camera.center, nextZoom.toDouble());
  }

  // =========================================================
  // MOVE TO POSITION
  // =========================================================

  void _moveToPosition(LatLng position, {double? zoom}) {
    final currentZoom = _mapController.camera.zoom;

    final requestedZoom = zoom ?? currentZoom;

    final safeZoom = requestedZoom.clamp(
      widget.config.camera.minZoom,
      widget.config.camera.maxZoom,
    );

    _mapController.move(position, safeZoom.toDouble());
  }

  // =========================================================
  // LOCATE ME
  // =========================================================

  void _locateMe(LatLng userPosition) {
    _moveToPosition(userPosition, zoom: widget.config.camera.initialZoom);
  }

  void _locateCurrentLocation() {
    final location = _currentLocation;

    if (location == null) {
      return;
    }

    _moveToPosition(
      LatLng(location.lat, location.lng),
      zoom: widget.config.camera.initialZoom,
    );
  }

  // =========================================================
  // MOVE TO SELECTED MARKER
  // =========================================================

  void _moveToMarker(MapMarkerData marker) {
    _moveToPosition(
      LatLng(marker.location.lat, marker.location.lng),
      zoom: widget.config.camera.initialZoom,
    );
  }

  // =========================================================
  // FIT BOUNDS
  // =========================================================

  void _fitBounds(List<LatLng> points, {double padding = 60}) {
    if (points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      _moveToPosition(points.first, zoom: widget.config.camera.initialZoom);

      return;
    }

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(padding),
        maxZoom: widget.config.camera.maxZoom,
      ),
    );
  }

  // =========================================================
  // FIT ALL MARKERS
  // =========================================================

  void _fitAllMarkers(LatLng userPosition) {
    final points = <LatLng>[
      userPosition,
      ...widget.markers.map(
        (marker) => LatLng(marker.location.lat, marker.location.lng),
      ),
    ];

    _fitBounds(points, padding: 60);
  }

  // =========================================================
  // EXTERNAL FIT ALL
  // =========================================================

  void _fitAllCurrentMarkers() {
    final points = <LatLng>[];

    final location = _currentLocation;

    if (location != null) {
      points.add(LatLng(location.lat, location.lng));
    }

    points.addAll(
      widget.markers.map(
        (marker) => LatLng(marker.location.lat, marker.location.lng),
      ),
    );

    _fitBounds(points, padding: 60);
  }

  // =========================================================
  // FIT ROUTE
  // =========================================================

  void _fitRoute() {
    if (!widget.config.route.show || !widget.config.widgets.showRoute) {
      return;
    }

    final route = widget.route;

    if (route == null || route.points.isEmpty) {
      return;
    }

    final points = route.points
        .map((point) => LatLng(point.lat, point.lng))
        .toList();

    _fitBounds(points, padding: 80);
  }

  // =========================================================
  // ROUTE LOADING
  // =========================================================

  Widget _buildRouteLoading(BuildContext context) {
    final builder = widget.config.widgets.routeLoadingBuilder;

    if (builder != null) {
      return builder(context);
    }

    return const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading route...'),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ROUTE INFO
  // =========================================================

  Widget _buildRouteInfo(BuildContext context, MapRoute route) {
    final builder = widget.config.widgets.routeInfoBuilder;

    if (builder != null) {
      return builder(context, route);
    }

    return RouteInfoCard(
      route: route,
      onClear: widget.onClearRoute ?? () {},
    );
  }

  // =========================================================
  // LOCATION LOADING
  // =========================================================

  Widget _buildLocationLoading(BuildContext context) {
    if (!widget.config.widgets.showLocationLoading) {
      return const SizedBox.shrink();
    }

    final builder = widget.config.widgets.locationLoadingBuilder;

    if (builder != null) {
      return builder(context);
    }

    return const Center(child: CircularProgressIndicator());
  }

  // =========================================================
  // LOCATION ERROR
  // =========================================================

  Widget _buildLocationError(BuildContext context, String message) {
    if (!widget.config.widgets.showLocationError) {
      return const SizedBox.shrink();
    }

    final builder = widget.config.widgets.locationErrorBuilder;

    if (builder != null) {
      return builder(context, message);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _mapController.dispose();

    super.dispose();
  }
}
