import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/map_location.dart';
import '../../domain/usecases/get_route.dart';
import 'route_state.dart';

class RouteCubit extends Cubit<RouteState> {
  final GetRoute getRoute;

  RouteCubit({required this.getRoute}) : super(const RouteInitial());

  Future<void> loadRoute({
    required MapLocation start,
    required MapLocation destination,
  }) async {
    emit(const RouteLoading());

    final result = await getRoute(start: start, destination: destination);

    result.fold(
      (failure) {
        emit(RouteError(failure.message));
      },
      (route) {
        emit(RouteLoaded(route));
      },
    );
  }

  void clearRoute() {
    emit(const RouteInitial());
  }
}
