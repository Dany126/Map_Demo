import 'package:flutter/material.dart';

class MapRouteConfig {
  final bool show;
  final Color color;
  final double strokeWidth;

  const MapRouteConfig({
    this.show = true,
    this.color = Colors.blue,
    this.strokeWidth = 5.0,
  });
}
