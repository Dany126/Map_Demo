import 'package:flutter/material.dart';

import '../../domain/entities/map_marker_data.dart';
import 'map_marker_theme.dart';

class DemoMarker extends StatelessWidget {
  final MapMarkerData marker;
  final MapMarkerTheme theme;
  final bool isSelected;

  const DemoMarker({
    super.key,
    required this.marker,
    required this.theme,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? theme.selectedWidth : theme.width,
      height: isSelected ? theme.selectedHeight : theme.height,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: isSelected ? 10 : 5,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          theme.icon,
          color: theme.color,
          size: isSelected ? theme.selectedIconSize : theme.iconSize,
        ),
      ),
    );
  }
}
