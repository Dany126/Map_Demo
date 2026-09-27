import 'package:flutter/material.dart';

import '../../domain/entities/map_marker_data.dart';

typedef MapMarkerBuilder = Widget Function(
  BuildContext context,
  MapMarkerData marker,
);

typedef SelectedMapMarkerBuilder = Widget Function(
  BuildContext context,
  MapMarkerData marker,
  bool isSelected,
);
