import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitAll;
  final VoidCallback onLocateMe;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitAll,
    required this.onLocateMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'zoom_in',
          onPressed: onZoomIn,
          child: const Icon(Icons.add),
        ),

        const SizedBox(height: 8),

        FloatingActionButton.small(
          heroTag: 'zoom_out',
          onPressed: onZoomOut,
          child: const Icon(Icons.remove),
        ),

        const SizedBox(height: 8),

        FloatingActionButton.small(
          heroTag: 'fit_all',
          onPressed: onFitAll,
          child: const Icon(Icons.fit_screen),
        ),

        const SizedBox(height: 16),

        FloatingActionButton(
          heroTag: 'locate_me',
          onPressed: onLocateMe,
          child: const Icon(Icons.my_location),
        ),
      ],
    );
  }
}
