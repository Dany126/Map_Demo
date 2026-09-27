import 'package:flutter/material.dart';

import '../../domain/entities/map_marker_data.dart';

class MarkerBottomSheet extends StatelessWidget {
  final MapMarkerData marker;
  final VoidCallback onShowRoute;

  const MarkerBottomSheet({
    super.key,
    required this.marker,
    required this.onShowRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDragHandle(),

            const SizedBox(height: 20),

            _buildHeader(),

            const SizedBox(height: 20),

            _buildLocation(),

            const SizedBox(height: 20),

            _buildShowRouteButton(),

            const SizedBox(height: 8),

            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildMarkerIcon(),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Marker ID: ${marker.id}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),

        const SizedBox(height: 6),

        Text(
          '${marker.location.lat}, ${marker.location.lng}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildShowRouteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onShowRoute,
        icon: const Icon(Icons.directions),
        label: const Text('Show Route'),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Close'),
      ),
    );
  }

  Widget _buildMarkerIcon() {
    switch (marker.type) {
      case 'restaurant':
        return _iconContainer(Icons.restaurant, Colors.red);

      case 'football':
        return _iconContainer(Icons.sports_soccer, Colors.green);

      case 'cinema':
        return _iconContainer(Icons.movie, Colors.purple);

      case 'cafe':
        return _iconContainer(Icons.local_cafe, Colors.brown);

      default:
        return _iconContainer(Icons.location_on, Colors.blue);
    }
  }

  Widget _iconContainer(IconData icon, Color color) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  String _getTitle() {
    switch (marker.type) {
      case 'restaurant':
        return 'Restaurant';

      case 'football':
        return 'Football';

      case 'cinema':
        return 'Cinema';

      case 'cafe':
        return 'Cafe';

      default:
        return 'Location';
    }
  }
}
