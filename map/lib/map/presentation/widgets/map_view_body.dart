import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:map/map/domain/entities/map_location.dart';
import 'package:map/map/domain/entities/map_marker_data.dart';
import 'package:map/map/domain/entities/map_route.dart';
import 'package:map/map/presentation/config/map_widgets_config.dart';

import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import 'map_control_actions.dart';
import 'map_controls.dart';
import 'map_controller_actions.dart';

class MapViewBody extends StatefulWidget {
  final List<MapMarkerData> markers;

  final MapRoute? route;

  final MapMarkerData? selectedMarker;

  final void Function(MapMarkerData marker)? onMarkerTap;

  final MapWidgetsConfig config;

  /// Gives external widgets controlled access to map actions
  /// without exposing the internal MapController.
  final void Function(MapControllerActions actions)? onMapReady;

  const MapViewBody({
    super.key,
    this.markers = const [],
    this.route,
    this.selectedMarker,
    this.onMarkerTap,
    this.config = const MapWidgetsConfig(),
    this.onMapReady,
  });

  @override
  State<MapViewBody> createState() => _MapViewBodyState();
}

class _MapViewBodyState extends State<MapViewBody> {
  final MapController _mapController = MapController();

  static const double _defaultZoom = 16;

  MapLocation? _currentLocation;

  bool _mapReadyNotified = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MapViewBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldSelectedId = oldWidget.selectedMarker?.id;

    final newSelectedId = widget.selectedMarker?.id;

    if (oldSelectedId != newSelectedId && widget.selectedMarker != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _moveToMarker(widget.selectedMarker!);
      });
    }

    if (oldWidget.route == null &&
        widget.route != null &&
        widget.config.showRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _fitRoute();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationLoading) {
          if (!widget.config.showLocationLoading) {
            return const SizedBox.shrink();
          }

          return _buildLocationLoading(context);
        }

        if (state is LocationError) {
          if (!widget.config.showLocationError) {
            return const SizedBox.shrink();
          }

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
            initialZoom: _defaultZoom,
          ),
          children: [
            _buildTileLayer(),

            if (widget.config.showRoute && widget.route != null)
              _buildRouteLayer(),

            _buildMarkerLayer(context, userPosition, location),
          ],
        ),

        if (widget.config.showControls)
          Positioned(
            right: 16,
            bottom: 30,
            child: _buildControls(context, userPosition),
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

    if (widget.onMapReady == null) {
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

      final actions = MapControllerActions(
        moveTo: _moveToPosition,
        fitBounds: _fitBounds,
        zoomIn: _zoomIn,
        zoomOut: _zoomOut,
        locateMe: _locateCurrentLocation,
        fitAll: _fitAllCurrentMarkers,
        fitRoute: _fitRoute,
      );

      widget.onMapReady?.call(actions);
    });
  }

  // =========================================================
  // TILE LAYER
  // =========================================================

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.map',
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
    return MarkerLayer(
      markers: [
        if (widget.config.showUserMarker)
          _buildUserMarker(
            context: context,
            position: userPosition,
            location: location,
          ),

        if (widget.config.showMarkers)
          ...widget.markers.map((marker) {
            return _buildMarker(context, marker);
          }),
      ],
    );
  }

  // =========================================================
  // USER MARKER
  // =========================================================

  Marker _buildUserMarker({
    required BuildContext context,
    required LatLng position,
    required MapLocation location,
  }) {
    final builder = widget.config.userMarkerBuilder;

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
            widget.config.markerBuilder?.call(context, marker, isSelected) ??
            Icon(
              Icons.location_on,
              size: isSelected ? 50 : 40,
              color: isSelected ? Colors.orange : Colors.blue,
            ),
      ),
    );
  }

  // =========================================================
  // ROUTE
  // =========================================================

  Widget _buildRouteLayer() {
    final route = widget.route!;

    return PolylineLayer(
      polylines: [
        Polyline(
          points: route.points
              .map((point) => LatLng(point.lat, point.lng))
              .toList(),
          strokeWidth: 5,
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
      canFitRoute: widget.route != null && widget.config.showRoute,
    );

    if (widget.config.controlsBuilder != null) {
      return widget.config.controlsBuilder!(context, actions);
    }

    return MapControls(actions: actions);
  }

  // =========================================================
  // ZOOM IN
  // =========================================================

  void _zoomIn() {
    final camera = _mapController.camera;

    final nextZoom = camera.zoom + 1;

    _mapController.move(camera.center, nextZoom);
  }

  // =========================================================
  // ZOOM OUT
  // =========================================================

  void _zoomOut() {
    final camera = _mapController.camera;

    final nextZoom = camera.zoom - 1;

    _mapController.move(camera.center, nextZoom);
  }

  // =========================================================
  // MOVE TO POSITION
  // =========================================================

  void _moveToPosition(LatLng position, {double? zoom}) {
    final currentZoom = _mapController.camera.zoom;

    _mapController.move(position, zoom ?? currentZoom);
  }

  // =========================================================
  // LOCATE ME
  // =========================================================

  void _locateMe(LatLng userPosition) {
    _mapController.move(userPosition, _defaultZoom);
  }

  void _locateCurrentLocation() {
    final location = _currentLocation;

    if (location == null) {
      return;
    }

    final position = LatLng(location.lat, location.lng);

    _mapController.move(position, _defaultZoom);
  }

  // =========================================================
  // MOVE TO SELECTED MARKER
  // =========================================================

  void _moveToMarker(MapMarkerData marker) {
    final position = LatLng(marker.location.lat, marker.location.lng);

    _mapController.move(position, _defaultZoom);
  }

  // =========================================================
  // FIT BOUNDS
  // =========================================================

  void _fitBounds(List<LatLng> points, {double padding = 60}) {
    if (points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      _mapController.move(points.first, _defaultZoom);

      return;
    }

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(padding)),
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
  // LOCATION LOADING
  // =========================================================

  Widget _buildLocationLoading(BuildContext context) {
    if (widget.config.locationLoadingBuilder != null) {
      return widget.config.locationLoadingBuilder!(context);
    }

    return const Center(child: CircularProgressIndicator());
  }

  // =========================================================
  // LOCATION ERROR
  // =========================================================

  Widget _buildLocationError(BuildContext context, String message) {
    if (widget.config.locationErrorBuilder != null) {
      return widget.config.locationErrorBuilder!(context, message);
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
