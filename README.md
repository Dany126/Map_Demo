# Flutter Map Package

A reusable and highly configurable Flutter map package built on top of [`flutter_map`](https://pub.dev/packages/flutter_map) and OpenStreetMap.

The package provides a clean foundation for location-based Flutter applications, including user location tracking, markers, marker selection, routing, camera controls, and customizable UI builders.

---

## ✨ Features

- 📍 Current user location
- 🔄 Real-time location tracking
- 📌 Custom map markers
- 🎯 Marker selection
- 🗺️ OpenStreetMap integration
- 🔍 Zoom in / Zoom out
- 📍 Locate user
- 🧭 Fit all markers
- 🛣️ Route calculation
- 📏 Route distance
- ⏱️ Route duration
- 📐 Route polyline
- 📋 Route information
- 🧩 Fully customizable widgets
- 🎨 Custom user marker
- 🎨 Custom marker builder
- 🎮 Custom map controls
- 📱 Responsive Flutter UI
- 🏗️ Clean Architecture
- 🔒 Encapsulated internal implementation

---

## 📦 Installation

### Git Dependency

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  map:
    git:
      url: https://github.com/Dany126/Map_Demo.git
      path: map
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Basic Usage

Import the package:

```dart
import 'package:map/map.dart';
```

Then use `MapView`:

```dart
MapView(
  markers: const [],
)
```

---

## 📍 Adding Markers

Create markers using `MapMarkerData`:

```dart
final markers = [
  MapMarkerData(
    id: 'venue_1',
    location: MapLocation(
      lat: 30.0444,
      lng: 31.2357,
    ),
    type: 'restaurant',
  ),
];
```

Then pass them to the map:

```dart
MapView(
  markers: markers,
)
```

---

## 🎨 Custom Markers

The package allows you to completely control how markers look.

```dart
MapView(
  markers: markers,
  config: MapViewConfig(
    widgets: MapWidgetsConfig(
      markerBuilder: (context, marker, isSelected) {
        return Container(
          width: isSelected ? 60 : 50,
          height: isSelected ? 60 : 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            Icons.location_on,
            color: Colors.red,
          ),
        );
      },
    ),
  ),
)
```

This allows the package to be used with different application designs without modifying the package internals.

---

## 👤 Custom User Marker

You can provide your own widget for the user's current location.

```dart
MapView(
  config: MapViewConfig(
    widgets: MapWidgetsConfig(
      userMarkerBuilder: (context, location) {
        return const Icon(
          Icons.person_pin_circle,
          size: 50,
        );
      },
    ),
  ),
)
```

This can also be used for custom avatars or 3D-avatar-based location indicators.

---

## ⚙️ Configuration

`MapViewConfig` provides configuration for the different parts of the map.

```dart
MapViewConfig(
  camera: const MapCameraConfig(
    initialZoom: 15,
    minZoom: 3,
    maxZoom: 19,
  ),

  interactions: const MapInteractionConfig(
    enableDrag: true,
    enablePinchZoom: true,
    enableRotate: true,
  ),

  tiles: const MapTileConfig(
    show: true,
  ),

  route: const MapRouteConfig(
    show: true,
    strokeWidth: 5,
  ),
)
```

The configuration is divided into:

- `MapCameraConfig`
- `MapTileConfig`
- `MapInteractionConfig`
- `MapRouteConfig`
- `MapWidgetsConfig`

---

## 🛣️ Routing

The package supports calculating routes between two locations.

A route contains:

```dart
MapRoute
```

with:

- Route points
- Distance
- Duration

Example:

```dart
MapRoute(
  points: points,
  distanceInMeters: 3500,
  durationInSeconds: 720,
);
```

The route can then be displayed on the map as a polyline.

---

## 🎮 Map Controller Actions

The package keeps the internal `flutter_map` controller private while exposing safe controller actions through:

```dart
MapControllerActions
```

Available actions include:

```dart
actions.moveTo(...)
actions.fitBounds(...)
actions.zoomIn()
actions.zoomOut()
actions.locateMe()
actions.fitAll()
actions.fitRoute()
```

You can receive these actions using:

```dart
MapView(
  onMapReady: (actions) {
    // Use map actions here.
  },
)
```

This keeps the underlying map implementation encapsulated while still allowing the application to control the map.

---

## 🎛️ Custom Controls

You can completely replace the default map controls.

```dart
MapView(
  config: MapViewConfig(
    widgets: MapWidgetsConfig(
      controlsBuilder: (context, actions) {
        return Column(
          children: [
            FloatingActionButton(
              onPressed: actions.zoomIn,
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: actions.zoomOut,
              child: const Icon(Icons.remove),
            ),
          ],
        );
      },
    ),
  ),
)
```

---

## 🧩 Custom UI Builders

The package provides builders for application-specific UI.

Available builders include:

- `userMarkerBuilder`
- `markerBuilder`
- `controlsBuilder`
- `routeInfoBuilder`
- `routeLoadingBuilder`
- `locationLoadingBuilder`
- `locationErrorBuilder`
- `markerBottomSheetBuilder`

This makes the map reusable across different applications and design systems.

---

## 🏗️ Architecture

The package follows a Clean Architecture-inspired structure:

```text
lib/
├── map.dart
└── src/
    ├── core/
    │   ├── config/
    │   ├── errors/
    │   └── utils/
    │
    └── map/
        ├── data/
        │   ├── models/
        │   └── repositories/
        │
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        │
        └── presentation/
            ├── config/
            ├── cubit/
            └── widgets/
```

The internal implementation is intentionally hidden from package consumers.

Applications should use only:

```dart
import 'package:map/map.dart';
```

---

## 📱 Example

The repository contains an example Flutter application demonstrating the package.

```text
example/
├── lib/
│   ├── demo_marker.dart
│   ├── demo_marker_themes.dart
│   └── main.dart
└── pubspec.yaml
```

Run the example:

```bash
cd example
flutter pub get
flutter run
```

---

## 🔐 Location Permissions

The package uses the device location services through `geolocator`.

### Android

Add the required location permission to:

```text
android/app/src/main/AndroidManifest.xml
```

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS

Add the location usage description to:

```text
ios/Runner/Info.plist
```

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location to show your position on the map.</string>
```

The application is responsible for providing the required platform configuration and handling the user's permission decision.

---

## 🗺️ Map Tiles

The default tile source is OpenStreetMap:

```text
https://tile.openstreetmap.org/{z}/{x}/{y}.png
```

You can replace the tile configuration using `MapTileConfig`.

Make sure your application follows the tile provider's usage policy and attribution requirements.

---

## 🛣️ Routing Provider

The current routing implementation uses the public OSRM routing service.

This is an implementation detail of the current package version and may be replaced with another routing provider in the future.

For production applications, review the routing provider's usage limits and policies before relying on the public service.

---

## ⚠️ Limitations

- The package currently depends on OpenStreetMap tiles.
- The default routing implementation uses OSRM.
- Platform location permissions must be configured by the host application.
- The package does not provide a backend for storing venues or user data.
- The package focuses on map functionality and does not define application-specific business logic.

---

## 🧪 Testing

Run package tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Run the example:

```bash
cd example
flutter analyze
flutter run
```

---

## 📂 Project Structure

```text
map/
├── lib/
│   ├── map.dart
│   └── src/
│
├── example/
│   ├── lib/
│   └── pubspec.yaml
│
├── test/
│
├── CHANGELOG.md
├── README.md
└── pubspec.yaml
```

---

## 📄 License

This project does not currently include an open-source license.

A license will be added when the project is prepared for open-source distribution.

---

## 👨‍💻 Author

**Dany Ashraf**

Flutter Developer | Software Engineering Student

GitHub: [Dany126](https://github.com/Dany126)
