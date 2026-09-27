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

class MapViewBody extends StatefulWidget {
  final List<MapMarkerData> markers;

  final MapRoute? route;

  final MapMarkerData? selectedMarker;

  final void Function(MapMarkerData marker)? onMarkerTap;

  final MapWidgetsConfig config;

  const MapViewBody({
    super.key,
    this.markers = const [],
    this.route,
    this.selectedMarker,
    this.onMarkerTap,
    this.config = const MapWidgetsConfig(),
  });

  @override
  State<MapViewBody> createState() => _MapViewBodyState();
}

class _MapViewBodyState extends State<MapViewBody> {
  final MapController _mapController = MapController();

  static const double _defaultZoom = 16;

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
          return _buildLoadedMap(context, state.mapLocation);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadedMap(BuildContext context, MapLocation location) {
    final userPosition = LatLng(location.lat, location.lng);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userPosition,
            initialZoom: _defaultZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.map',
            ),

            if (widget.config.showRoute && widget.route != null)
              _buildRouteLayer(),

            MarkerLayer(
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
            ),
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

  Widget _buildLocationLoading(BuildContext context) {
    if (widget.config.locationLoadingBuilder != null) {
      return widget.config.locationLoadingBuilder!(context);
    }

    return const Center(child: CircularProgressIndicator());
  }

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

  Marker _buildUserMarker({
    required BuildContext context,
    required LatLng position,
    required MapLocation location,
  }) {
    final marker = MapMarkerData(id: 'user', location: location, type: 'user');

    return Marker(
      point: position,
      width: 50,
      height: 50,
      child:
          widget.config.userMarkerBuilder?.call(context, marker) ??
          const Icon(Icons.location_pin, size: 45, color: Colors.red),
    );
  }

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

  void _zoomIn() {
    final camera = _mapController.camera;

    _mapController.move(camera.center, camera.zoom + 1);
  }

  void _zoomOut() {
    final camera = _mapController.camera;

    _mapController.move(camera.center, camera.zoom - 1);
  }

  void _locateMe(LatLng userPosition) {
    _mapController.move(userPosition, _defaultZoom);
  }

  void _moveToMarker(MapMarkerData marker) {
    final position = LatLng(marker.location.lat, marker.location.lng);

    _mapController.move(position, _defaultZoom);
  }

  void _fitAllMarkers(LatLng userPosition) {
    final points = <LatLng>[
      userPosition,

      ...widget.markers.map(
        (marker) => LatLng(marker.location.lat, marker.location.lng),
      ),
    ];

    if (points.isEmpty) {
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  void _fitRoute() {
    final route = widget.route;

    if (route == null || route.points.isEmpty) {
      return;
    }

    final points = route.points
        .map((point) => LatLng(point.lat, point.lng))
        .toList();

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(80),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();

    super.dispose();
  }
}
