import 'package:flutter/material.dart';

class MapMarkerTheme {
  final IconData icon;
  final Color color;

  final double width;
  final double height;

  final double selectedWidth;
  final double selectedHeight;

  final double iconSize;
  final double selectedIconSize;

  final Color backgroundColor;

  const MapMarkerTheme({
    required this.icon,
    required this.color,
    this.width = 48,
    this.height = 48,
    this.selectedWidth = 58,
    this.selectedHeight = 58,
    this.iconSize = 28,
    this.selectedIconSize = 34,
    this.backgroundColor = Colors.white,
  });
}
