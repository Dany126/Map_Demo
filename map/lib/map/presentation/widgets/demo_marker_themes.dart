import 'package:flutter/material.dart';

import 'map_marker_theme.dart';

class DemoMarkerThemes {
  static const restaurant = MapMarkerTheme(
    icon: Icons.restaurant,
    color: Colors.red,
  );

  static const football = MapMarkerTheme(
    icon: Icons.sports_soccer,
    color: Colors.green,
  );

  static const cinema = MapMarkerTheme(icon: Icons.movie, color: Colors.purple);

  static const cafe = MapMarkerTheme(
    icon: Icons.local_cafe,
    color: Colors.brown,
  );

  static const defaultTheme = MapMarkerTheme(
    icon: Icons.location_on,
    color: Colors.blue,
    iconSize: 40,
    selectedIconSize: 45,
  );
}
