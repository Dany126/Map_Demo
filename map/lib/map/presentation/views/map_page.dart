import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:map/core/di/injection_container.dart';
import 'package:map/map/domain/entities/map_location.dart';
import 'package:map/map/domain/entities/map_marker_data.dart';
import 'package:map/map/domain/entities/map_route.dart';
import 'package:map/map/presentation/cubit/location_cubit.dart';
import 'package:map/map/presentation/cubit/location_state.dart';
import 'package:map/map/presentation/cubit/map_cubit.dart';
import 'package:map/map/presentation/cubit/map_state.dart';
import 'package:map/map/presentation/cubit/route_cubit.dart';
import 'package:map/map/presentation/cubit/route_state.dart';
import 'package:map/map/presentation/widgets/map_view_body.dart';
import 'package:map/map/presentation/widgets/route_info_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  MapMarkerData? _selectedMarker;

  @override
  Widget build(BuildContext context) {
    final markers = [
      const MapMarkerData(
        id: 'restaurant_1',
        type: 'restaurant',
        location: MapLocation(lat: 30.0444, lng: 31.2357),
      ),
      const MapMarkerData(
        id: 'football_1',
        type: 'football',
        location: MapLocation(lat: 30.0480, lng: 31.2400),
      ),
      const MapMarkerData(
        id: 'cinema_1',
        type: 'cinema',
        location: MapLocation(lat: 30.0410, lng: 31.2300),
      ),
      const MapMarkerData(
        id: 'cafe_1',
        type: 'cafe',
        location: MapLocation(lat: 30.0500, lng: 31.2280),
      ),
    ];

    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<LocationCubit>()
              ..getCurrentLocation()
              ..startLocationTracking(),
          ),
          BlocProvider(create: (_) => getIt<MapCubit>()),
          BlocProvider(create: (_) => getIt<RouteCubit>()),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<MapCubit, MapState>(
              listener: (context, state) {
                if (state is MapMarkerSelected) {
                  _selectedMarker = state.marker;

                  _showMarkerBottomSheet(context, state.marker);
                }
              },
            ),

            BlocListener<RouteCubit, RouteState>(
              listener: (context, state) {
                if (state is RouteError) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
          ],
          child: BlocBuilder<RouteCubit, RouteState>(
            builder: (context, routeState) {
              MapRoute? route;

              if (routeState is RouteLoaded) {
                route = routeState.route;
              }

              return Stack(
                children: [
                  MapViewBody(
                    markers: markers,
                    route: route,
                    selectedMarker: _selectedMarker,
                    onMarkerTap: (marker) {
                      context.read<MapCubit>().selectMarker(marker);
                    },
                    userMarkerBuilder: (context, marker) {
                      return const Icon(
                        Icons.person_pin_circle,
                        size: 45,
                        color: Colors.red,
                      );
                    },
                    otherMarkerBuilder: (context, marker, isSelected) {
                      return _buildMarkerIcon(marker, isSelected);
                    },
                  ),

                  if (routeState is RouteLoading)
                    const Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Loading route...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (route != null)
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: RouteInfoCard(
                        route: route,
                        onClear: () {
                          context.read<RouteCubit>().clearRoute();
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Marker Bottom Sheet
  // ===========================================================================

  void _showMarkerBottomSheet(BuildContext context, MapMarkerData marker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _MarkerBottomSheet(
          marker: marker,
          onShowRoute: () {
            Navigator.pop(bottomSheetContext);

            _requestRoute(context, marker);
          },
        );
      },
    );
  }

  // ===========================================================================
  // Route
  // ===========================================================================

  void _requestRoute(BuildContext context, MapMarkerData destination) {
    final locationState = context.read<LocationCubit>().state;

    if (locationState is! LocationLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location is not available yet.')),
      );

      return;
    }

    final start = locationState.mapLocation;

    context.read<RouteCubit>().loadRoute(
      start: start,
      destination: destination.location,
    );
  }

  // ===========================================================================
  // Marker UI
  // ===========================================================================

  Widget _buildMarkerIcon(MapMarkerData marker, bool isSelected) {
    final size = isSelected ? 34.0 : 28.0;

    switch (marker.type) {
      case 'restaurant':
        return _buildIconContainer(
          icon: Icons.restaurant,
          color: Colors.red,
          size: size,
          isSelected: isSelected,
        );

      case 'football':
        return _buildIconContainer(
          icon: Icons.sports_soccer,
          color: Colors.green,
          size: size,
          isSelected: isSelected,
        );

      case 'cinema':
        return _buildIconContainer(
          icon: Icons.movie,
          color: Colors.purple,
          size: size,
          isSelected: isSelected,
        );

      case 'cafe':
        return _buildIconContainer(
          icon: Icons.local_cafe,
          color: Colors.brown,
          size: size,
          isSelected: isSelected,
        );

      default:
        return _buildIconContainer(
          icon: Icons.location_on,
          color: isSelected ? Colors.orange : Colors.blue,
          size: isSelected ? 45 : 40,
          isSelected: isSelected,
        );
    }
  }

  Widget _buildIconContainer({
    required IconData icon,
    required Color color,
    required double size,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? 58 : 48,
      height: isSelected ? 58 : 48,
      decoration: BoxDecoration(
        color: Colors.white,
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
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

// =============================================================================
// Marker Bottom Sheet
// =============================================================================

class _MarkerBottomSheet extends StatelessWidget {
  final MapMarkerData marker;
  final VoidCallback onShowRoute;

  const _MarkerBottomSheet({required this.marker, required this.onShowRoute});

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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _buildBottomSheetIcon(),

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
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'Location',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 6),

            Text(
              '${marker.location.lat}, ${marker.location.lng}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onShowRoute,
                icon: const Icon(Icons.directions),
                label: const Text('Show Route'),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetIcon() {
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
