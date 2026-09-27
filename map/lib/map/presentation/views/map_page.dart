import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/core/di/injection_container.dart';
import 'package:map/map/presentation/cubit/location_cubit.dart';
import 'package:map/map/presentation/widgets/map_view_body.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => getIt<LocationCubit>()
          ..getCurrentLocation()
          ..startLocationTracking(),
        child: const MapViewBody(),
      ),
    );
  }
}
