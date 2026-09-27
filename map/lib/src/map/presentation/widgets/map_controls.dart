import 'package:flutter/material.dart';

import 'map_control_actions.dart';

class MapControls extends StatelessWidget {
  final MapControlActions actions;

  const MapControls({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'zoom_in',
          onPressed: actions.zoomIn,
          child: const Icon(Icons.add),
        ),

        const SizedBox(height: 8),

        FloatingActionButton.small(
          heroTag: 'zoom_out',
          onPressed: actions.zoomOut,
          child: const Icon(Icons.remove),
        ),

        const SizedBox(height: 8),

        FloatingActionButton.small(
          heroTag: 'fit_all',
          onPressed: actions.fitAll,
          child: const Icon(Icons.fit_screen),
        ),

        if (actions.canFitRoute) ...[
          const SizedBox(height: 8),

          FloatingActionButton.small(
            heroTag: 'fit_route',
            onPressed: actions.fitRoute,
            child: const Icon(Icons.route),
          ),
        ],

        const SizedBox(height: 16),

        FloatingActionButton(
          heroTag: 'locate_me',
          onPressed: actions.locateMe,
          child: const Icon(Icons.my_location),
        ),
      ],
    );
  }
}
