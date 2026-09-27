import 'package:flutter/material.dart';

import '../../domain/entities/map_route.dart';

class RouteInfoCard extends StatelessWidget {
  final MapRoute route;
  final VoidCallback onClear;

  const RouteInfoCard({super.key, required this.route, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.route, size: 28),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Route',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${route.distanceInKilometers.toStringAsFixed(1)} km'
                    ' • '
                    '${route.durationInMinutes} min',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Clear route',
              onPressed: onClear,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
