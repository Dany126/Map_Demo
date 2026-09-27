import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:map/map/domain/entities/map_location.dart';
import 'package:map/map/domain/entities/map_marker_data.dart';
import 'package:map/map/presentation/widgets/map_marker_builder.dart';

import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import 'map_controls.dart';

class MapViewBody extends StatefulWidget {
  final List<MapMarkerData> markers;

  final MapMarkerBuilder? userMarkerBuilder;

  final SelectedMapMarkerBuilder? otherMarkerBuilder;

  final MapMarkerData? selectedMarker;

  final void Function(MapMarkerData marker)? onMarkerTap;

  const MapViewBody({
    super.key,
    this.markers = const [],
    this.userMarkerBuilder,
    this.otherMarkerBuilder,
    this.selectedMarker,
    this.onMarkerTap,
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
      _moveToMarker(widget.selectedMarker!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LocationError) {
          return Center(
            child: Text(state.message, textAlign: TextAlign.center),
          );
        }

        if (state is LocationLoaded) {
          final location = state.mapLocation;

          final userPosition = LatLng(location.lat, location.lng);

          return _buildMap(
            context: context,
            userPosition: userPosition,
            userLocation: location,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMap({
    required BuildContext context,
    required LatLng userPosition,
    required MapLocation userLocation,
  }) {
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

            MarkerLayer(
              markers: [
                _buildUserMarker(
                  context: context,
                  position: userPosition,
                  location: userLocation,
                ),

                ...widget.markers.map(
                  (marker) => _buildMarker(context, marker),
                ),
              ],
            ),
          ],
        ),

        Positioned(
          right: 16,
          bottom: 30,
          child: MapControls(
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
            onLocateMe: () {
              _locateMe(userPosition);
            },
            onFitAll: () {
              _fitAllMarkers(userPosition);
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Camera Controls
  // ---------------------------------------------------------------------------

  void _zoomIn() {
    final camera = _mapController.camera;

    final newZoom = camera.zoom + 1;

    _mapController.move(camera.center, newZoom);
  }

  void _zoomOut() {
    final camera = _mapController.camera;

    final newZoom = camera.zoom - 1;

    _mapController.move(camera.center, newZoom);
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

  // ---------------------------------------------------------------------------
  // User Marker
  // ---------------------------------------------------------------------------

  Marker _buildUserMarker({
    required BuildContext context,
    required LatLng position,
    required MapLocation location,
  }) {
    final userMarker = MapMarkerData(
      id: 'user',
      location: location,
      type: 'user',
    );

    return Marker(
      point: position,
      width: 50,
      height: 50,
      child:
          widget.userMarkerBuilder?.call(context, userMarker) ??
          const Icon(Icons.location_pin, size: 45, color: Colors.red),
    );
  }

  // ---------------------------------------------------------------------------
  // Generic Marker
  // ---------------------------------------------------------------------------

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
            widget.otherMarkerBuilder?.call(context, marker, isSelected) ??
            Icon(
              Icons.location_on,
              size: isSelected ? 50 : 40,
              color: isSelected ? Colors.orange : Colors.blue,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();

    super.dispose();
  }
}
