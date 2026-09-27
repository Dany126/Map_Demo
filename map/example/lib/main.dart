import 'package:flutter/material.dart';
import 'package:map/map.dart';

import 'demo_marker.dart';
import 'demo_marker_themes.dart';

void main() {
  runApp(const MapExampleApp());
}

class MapExampleApp extends StatelessWidget {
  const MapExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Map Package Example',
      debugShowCheckedModeBanner: false,
      home: MapExamplePage(),
    );
  }
}

class MapExamplePage extends StatefulWidget {
  const MapExamplePage({super.key});

  @override
  State<MapExamplePage> createState() => _MapExamplePageState();
}

class _MapExamplePageState extends State<MapExamplePage> {
  MapControllerActions? _mapActions;

  final List<MapMarkerData> _markers = const [
    MapMarkerData(
      id: 'restaurant_1',
      type: 'restaurant',
      location: MapLocation(lat: 30.0444, lng: 31.2357),
    ),
    MapMarkerData(
      id: 'football_1',
      type: 'football',
      location: MapLocation(lat: 30.0480, lng: 31.2400),
    ),
    MapMarkerData(
      id: 'cinema_1',
      type: 'cinema',
      location: MapLocation(lat: 30.0410, lng: 31.2300),
    ),
    MapMarkerData(
      id: 'cafe_1',
      type: 'cafe',
      location: MapLocation(lat: 30.0500, lng: 31.2280),
    ),
  ];

  static MapMarkerTheme _getMarkerTheme(MapMarkerData marker) {
    switch (marker.type) {
      case 'restaurant':
        return DemoMarkerThemes.restaurant;
      case 'football':
        return DemoMarkerThemes.football;
      case 'cinema':
        return DemoMarkerThemes.cinema;
      case 'cafe':
        return DemoMarkerThemes.cafe;
      default:
        return DemoMarkerThemes.defaultTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapConfig = MapViewConfig(
      camera: const MapCameraConfig(
        initialZoom: 16,
        minZoom: 3,
        maxZoom: 19,
      ),
      tiles: const MapTileConfig(
        show: true,
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.map',
      ),
      route: const MapRouteConfig(
        show: true,
        color: Colors.blue,
        strokeWidth: 5,
      ),
      interactions: const MapInteractionConfig(
        enableDrag: true,
        enablePinchMove: true,
        enablePinchZoom: true,
        enableDoubleTapZoom: true,
        enableScrollWheelZoom: true,
        enableRotate: true,
      ),
      widgets: MapWidgetsConfig(
        showUserMarker: true,
        showMarkers: true,
        showRoute: true,
        showControls: true,
        showRouteInfo: true,
        showRouteLoading: true,
        showLocationLoading: true,
        showLocationError: true,
        showMarkerBottomSheet: true,
        userMarkerBuilder: (context, location) {
          return const Icon(
            Icons.person_pin_circle,
            size: 45,
            color: Colors.red,
          );
        },
        markerBuilder: (context, marker, isSelected) {
          return DemoMarker(
            marker: marker,
            isSelected: isSelected,
            theme: _getMarkerTheme(marker),
          );
        },
        routeLoadingBuilder: (context) {
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
        },
        locationLoadingBuilder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
        locationErrorBuilder: (context, message) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(message, textAlign: TextAlign.center),
            ),
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Demo Example'),
        actions: [
          IconButton(
            tooltip: 'Fit All Markers',
            icon: const Icon(Icons.fullscreen),
            onPressed: () => _mapActions?.fitAll(),
          ),
          IconButton(
            tooltip: 'Locate Me',
            icon: const Icon(Icons.my_location),
            onPressed: () => _mapActions?.locateMe(),
          ),
        ],
      ),
      body: MapView(
        markers: _markers,
        config: mapConfig,
        onMapReady: (actions) {
          _mapActions = actions;
        },
        onMarkerTap: (marker) {
          debugPrint('Tapped marker: ${marker.id}');
        },
      ),
    );
  }
}
