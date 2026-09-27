import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/location_repository_impl.dart';
import '../../data/repositories/route_repository_impl.dart';
import '../../domain/entities/map_marker_data.dart';
import '../../domain/entities/map_route.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/route_repository.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_route.dart';
import '../../domain/usecases/watch_location.dart';
import '../config/map_view_config.dart';
import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../cubit/route_cubit.dart';
import '../cubit/route_state.dart';
import 'map_controller_actions.dart';
import 'map_view_body.dart';
import 'marker_bottom_sheet.dart';

/// The main entry point widget for displaying a fully-featured, configurable map.
///
/// Encapsulates location tracking, routing, marker selection, and bottom sheets
/// with full customizability via [MapViewConfig].
class MapView extends StatefulWidget {
  final List<MapMarkerData> markers;
  final MapViewConfig config;
  final void Function(MapMarkerData marker)? onMarkerTap;
  final void Function(MapControllerActions actions)? onMapReady;
  final LocationRepository? locationRepository;
  final RouteRepository? routeRepository;

  const MapView({
    super.key,
    this.markers = const [],
    this.config = const MapViewConfig(),
    this.onMarkerTap,
    this.onMapReady,
    this.locationRepository,
    this.routeRepository,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final LocationRepository _locationRepository;
  late final RouteRepository _routeRepository;
  late final LocationCubit _locationCubit;
  late final MapCubit _mapCubit;
  late final RouteCubit _routeCubit;

  @override
  void initState() {
    super.initState();

    _locationRepository =
        widget.locationRepository ?? LocationRepositoryImpl();
    _routeRepository =
        widget.routeRepository ?? RouteRepositoryImpl(dio: Dio());

    _locationCubit = LocationCubit(
      getcurrentlocation: GetCurrentLocation(repo: _locationRepository),
      getlivelocation: GetLiveLocation(repo: _locationRepository),
    )
      ..getCurrentLocation()
      ..startLocationTracking();

    _mapCubit = MapCubit();
    _routeCubit = RouteCubit(
      getRoute: GetRoute(repository: _routeRepository),
    );
  }

  @override
  void dispose() {
    _locationCubit.close();
    _mapCubit.close();
    _routeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationCubit>.value(value: _locationCubit),
        BlocProvider<MapCubit>.value(value: _mapCubit),
        BlocProvider<RouteCubit>.value(value: _routeCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<MapCubit, MapState>(
            listener: (context, state) {
              if (state is MapMarkerSelected &&
                  widget.config.widgets.showMarkerBottomSheet) {
                _showMarkerBottomSheet(context, state.marker);
              }
            },
          ),
          BlocListener<RouteCubit, RouteState>(
            listener: (context, state) {
              if (state is RouteError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
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
                  markers: widget.markers,
                  route: route,
                  selectedMarker: selectedMarker,
                  isRouteLoading: routeState is RouteLoading,
                  onClearRoute: () {
                    _routeCubit.clearRoute();
                  },
                  onMarkerTap: (marker) {
                    widget.onMarkerTap?.call(marker);
                    _mapCubit.selectMarker(marker);
                  },
                  onMapReady: widget.onMapReady,
                  config: widget.config,
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showMarkerBottomSheet(BuildContext context, MapMarkerData marker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return widget.config.widgets.markerBottomSheetBuilder?.call(
              bottomSheetContext,
              marker,
              () {
                Navigator.pop(bottomSheetContext);
                _requestRoute(marker);
              },
            ) ??
            MarkerBottomSheet(
              marker: marker,
              onShowRoute: () {
                Navigator.pop(bottomSheetContext);
                _requestRoute(marker);
              },
            );
      },
    ).whenComplete(() {
      _mapCubit.clearSelectedMarker();
    });
  }

  void _requestRoute(MapMarkerData destination) {
    final locationState = _locationCubit.state;

    if (locationState is! LocationLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location is not available yet.')),
      );
      return;
    }

    final start = locationState.mapLocation;

    _routeCubit.loadRoute(
      start: start,
      destination: destination.location,
    );
  }
}
