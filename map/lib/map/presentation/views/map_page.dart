import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:map/core/di/injection_container.dart';
import 'package:map/map/domain/entities/map_location.dart';
import 'package:map/map/domain/entities/map_marker_data.dart';
import 'package:map/map/domain/entities/map_route.dart';
import 'package:map/map/presentation/config/map_camera_config.dart';
import 'package:map/map/presentation/config/map_interaction_config.dart';
import 'package:map/map/presentation/config/map_route_config.dart';
import 'package:map/map/presentation/config/map_tile_config.dart';
import 'package:map/map/presentation/config/map_view_config.dart';
import 'package:map/map/presentation/config/map_widgets_config.dart';
import 'package:map/map/presentation/cubit/location_cubit.dart';
import 'package:map/map/presentation/cubit/location_state.dart';
import 'package:map/map/presentation/cubit/map_cubit.dart';
import 'package:map/map/presentation/cubit/map_state.dart';
import 'package:map/map/presentation/cubit/route_cubit.dart';
import 'package:map/map/presentation/cubit/route_state.dart';
import 'package:map/map/presentation/widgets/demo_marker.dart';
import 'package:map/map/presentation/widgets/demo_marker_themes.dart';
import 'package:map/map/presentation/widgets/map_controller_actions.dart';
import 'package:map/map/presentation/widgets/map_marker_theme.dart';
import 'package:map/map/presentation/widgets/map_view_body.dart';
import 'package:map/map/presentation/widgets/marker_bottom_sheet.dart';
import 'package:map/map/presentation/widgets/route_info_card.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

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

    final mapConfig = MapViewConfig(
      // =====================================================
      // CAMERA
      // =====================================================

      camera: const MapCameraConfig(initialZoom: 16, minZoom: 3, maxZoom: 19),

      // =====================================================
      // TILES
      // =====================================================
      tiles: const MapTileConfig(
        show: true,
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.map',
      ),

      // =====================================================
      // ROUTE
      // =====================================================
      route: const MapRouteConfig(
        show: true,
        color: Colors.blue,
        strokeWidth: 5,
      ),

      // =====================================================
      // INTERACTIONS
      // =====================================================
      interactions: const MapInteractionConfig(
        enableDrag: true,
        enablePinchMove: true,
        enablePinchZoom: true,
        enableDoubleTapZoom: true,
        enableScrollWheelZoom: true,
        enableRotate: true,
      ),

      // =====================================================
      // WIDGETS
      // =====================================================
      widgets: MapWidgetsConfig(
        // ---------------------------------------------------
        // VISIBILITY
        // ---------------------------------------------------

        showUserMarker: true,
        showMarkers: true,
        showRoute: true,
        showControls: true,
        showRouteInfo: true,
        showRouteLoading: true,
        showLocationLoading: true,
        showLocationError: true,
        showMarkerBottomSheet: true,

        // ---------------------------------------------------
        // USER MARKER
        // ---------------------------------------------------
        userMarkerBuilder: (context, location) {
          return const Icon(
            Icons.person_pin_circle,
            size: 45,
            color: Colors.red,
          );
        },

        // ---------------------------------------------------
        // OTHER MARKERS
        // ---------------------------------------------------
        markerBuilder: (context, marker, isSelected) {
          return DemoMarker(
            marker: marker,
            isSelected: isSelected,
            theme: _getMarkerTheme(marker),
          );
        },

        // ---------------------------------------------------
        // ROUTE LOADING
        // ---------------------------------------------------
        routeLoadingBuilder: (context) {
          return const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading route...'),
                  ],
                ),
              ),
            ),
          );
        },

        // ---------------------------------------------------
        // ROUTE INFO
        // ---------------------------------------------------
        routeInfoBuilder: (context, route) {
          return RouteInfoCard(
            route: route,
            onClear: () {
              context.read<RouteCubit>().clearRoute();
            },
          );
        },

        // ---------------------------------------------------
        // LOCATION LOADING
        // ---------------------------------------------------
        locationLoadingBuilder: (context) {
          return const Center(child: CircularProgressIndicator());
        },

        // ---------------------------------------------------
        // LOCATION ERROR
        // ---------------------------------------------------
        locationErrorBuilder: (context, message) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(message, textAlign: TextAlign.center),
            ),
          );
        },

        // ---------------------------------------------------
        // MARKER BOTTOM SHEET
        // ---------------------------------------------------
        markerBottomSheetBuilder: (context, marker, onShowRoute) {
          return MarkerBottomSheet(marker: marker, onShowRoute: onShowRoute);
        },
      ),
    );

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
            // =================================================
            // MARKER SELECTION
            // =================================================

            BlocListener<MapCubit, MapState>(
              listener: (context, state) {
                if (state is MapMarkerSelected &&
                    mapConfig.widgets.showMarkerBottomSheet) {
                  _showMarkerBottomSheet(context, state.marker, mapConfig);
                }
              },
            ),

            // =================================================
            // ROUTE ERROR
            // =================================================
            BlocListener<RouteCubit, RouteState>(
              listener: (context, state) {
                if (state is RouteError) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
          ],

          child: BlocSelector<MapCubit, MapState, MapMarkerData?>(
            selector: (state) {
              if (state is MapMarkerSelected) {
                return state.marker;
              }

              return null;
            },

            builder: (context, selectedMarker) {
              return BlocBuilder<RouteCubit, RouteState>(
                builder: (context, routeState) {
                  MapRoute? route;

                  if (routeState is RouteLoaded) {
                    route = routeState.route;
                  }

                  return MapViewBody(
                    markers: markers,

                    route: route,

                    selectedMarker: selectedMarker,

                    isRouteLoading: routeState is RouteLoading,

                    onClearRoute: () {
                      context.read<RouteCubit>().clearRoute();
                    },

                    onMarkerTap: (marker) {
                      context.read<MapCubit>().selectMarker(marker);
                    },

                    onMapReady: (MapControllerActions actions) {
                      // The map is now ready.
                      //
                      // You can store/use these
                      // actions from an external
                      // controller later.
                      //
                      // Example:
                      //
                      // actions.zoomIn();
                      //
                      // actions.moveTo(
                      //   LatLng(
                      //     30.0444,
                      //     31.2357,
                      //   ),
                      //   zoom: 17,
                      // );
                    },

                    config: mapConfig,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // MARKER BOTTOM SHEET
  // ===========================================================

  void _showMarkerBottomSheet(
    BuildContext context,
    MapMarkerData marker,
    MapViewConfig config,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return config.widgets.markerBottomSheetBuilder?.call(
              bottomSheetContext,
              marker,
              () {
                Navigator.pop(bottomSheetContext);

                _requestRoute(context, marker);
              },
            ) ??
            MarkerBottomSheet(
              marker: marker,
              onShowRoute: () {
                Navigator.pop(bottomSheetContext);

                _requestRoute(context, marker);
              },
            );
      },
    );
  }

  // ===========================================================
  // REQUEST ROUTE
  // ===========================================================

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

  // ===========================================================
  // MARKER THEME
  // ===========================================================

  static MapMarkerTheme _getMarkerTheme(MapMarkerData marker) {
    switch (marker.type) {
      case 'restaurant':
        return DemoMarkerThemes.restaurant;

      case 'football':
        return DemoMarkerThemes.football;

      case 'cinema':
        return DemoMarkerThemes.cinema;

      case 'cafe':
        return DemoMarkerThemes.cafe;

      default:
        return DemoMarkerThemes.defaultTheme;
    }
  }
}
