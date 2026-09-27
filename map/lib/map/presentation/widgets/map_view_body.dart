import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:map/core/utils/app_constants.dart';
import 'package:map/map/presentation/cubit/location_cubit.dart';
import 'package:map/map/presentation/cubit/location_state.dart';

class MapViewBody extends StatefulWidget {
  const MapViewBody({super.key});

  @override
  State<MapViewBody> createState() => _MapViewBodyState();
}

class _MapViewBodyState extends State<MapViewBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          if (state is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LocationError) {
            return Center(child: Text(state.message));
          } else if (state is LocationLoaded) {
            return Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialZoom: 18,
                    initialCenter: state.position,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: AppConstants.osrmTileUrl,
                      userAgentPackageName: 'com.example.map',
                      maxZoom: 19,
                    ),
                  ],
                ),
              ],
            );
          }

          return const SizedBox.shrink(); // Fallback when state is LocationInitial or unknown
        },
      ),
    );
  }
}
