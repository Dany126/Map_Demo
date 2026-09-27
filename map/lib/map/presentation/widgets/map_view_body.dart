import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';

class MapViewBody extends StatefulWidget {
  const MapViewBody({super.key});

  @override
  State<MapViewBody> createState() => _MapViewBodyState();
}

class _MapViewBodyState extends State<MapViewBody> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LocationError) {
          return Center(child: Text(state.message));
        }

        if (state is LocationLoaded) {
          final location = state.mapLocation;

          final userPosition = LatLng(location.lat, location.lng);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userPosition,
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.map',
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: userPosition,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_pin,
                          size: 45,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Positioned(
                right: 16,
                bottom: 30,
                child: FloatingActionButton(
                  onPressed: () {
                    _mapController.move(userPosition, 16);
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
