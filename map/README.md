# Map Flutter Package

A clean, modular, and highly configurable Flutter Map package built on top of [`flutter_map`](https://pub.dev/packages/flutter_map) and OpenStreetMap.

---

## Features

- **Location**: GPS location detection, permission handling, and continuous location streaming.
- **Markers**: Generic markers with support for custom themes, interactive selection, and custom builders.
- **Routing**: Turn-by-turn routing powered by OSRM, complete with distance, duration, and customizable polylines.
- **Configuration**: Separate configurations for Camera, Map Tiles, Polylines, Gestures/Interactions, and Widget Visibility/Builders.
- **Map Controller**: Controlled external camera API via `MapControllerActions` (`moveTo`, `fitBounds`, `zoomIn`, `zoomOut`, `locateMe`, `fitAll`, `fitRoute`).
- **Clean Architecture**: Decoupled domain entities, use cases, and repositories with internal BLoC state management.

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  map:
    path: path/to/map # Or git/pub reference
```

---

## Platform Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location when open.</string>
```

---

## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:map/map.dart';

class SimpleMapScreen extends StatelessWidget {
  const SimpleMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapView(
        markers: const [
          MapMarkerData(
            id: 'place_1',
            type: 'restaurant',
            location: MapLocation(lat: 30.0444, lng: 31.2357),
          ),
        ],
      ),
    );
  }
}
```

---

## Custom Configuration

```dart
final config = MapViewConfig(
  camera: const MapCameraConfig(
    initialZoom: 15,
    minZoom: 4,
    maxZoom: 19,
  ),
  tiles: const MapTileConfig(
    show: true,
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.example.app',
  ),
  route: const MapRouteConfig(
    show: true,
    color: Colors.blue,
    strokeWidth: 6,
  ),
  interactions: const MapInteractionConfig(
    enableDrag: true,
    enablePinchZoom: true,
    enableDoubleTapZoom: true,
    enableScrollWheelZoom: true,
    enableRotate: false,
  ),
  widgets: MapWidgetsConfig(
    showUserMarker: true,
    showMarkers: true,
    showControls: true,
    showRouteInfo: true,
    showMarkerBottomSheet: true,
    userMarkerBuilder: (context, location) {
      return const Icon(Icons.person_pin, size: 45, color: Colors.red);
    },
    markerBuilder: (context, marker, isSelected) {
      return Icon(
        Icons.location_on,
        size: isSelected ? 50 : 40,
        color: isSelected ? Colors.orange : Colors.blue,
      );
    },
  ),
);
```

---

## External Camera Control (`MapControllerActions`)

```dart
MapView(
  markers: markers,
  config: config,
  onMapReady: (MapControllerActions actions) {
    // Zoom in
    actions.zoomIn();

    // Center on specific coordinates
    actions.moveTo(const LatLng(30.0444, 31.2357), zoom: 17);

    // Fit all markers
    actions.fitAll();

    // Fit route
    actions.fitRoute();
  },
)
```

---

## Supported Platforms

- Android
- iOS
- Web
- macOS / Windows / Linux

---

## Current Limitations

- Routing is currently configured for driving profiles via the public OSRM demo server. For high-volume production use, provide a dedicated routing server.
- Polyline rendering currently displays one active route at a time.
