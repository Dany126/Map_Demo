import '../../domain/entities/map_route.dart';

sealed class RouteState {
  const RouteState();
}

class RouteInitial extends RouteState {
  const RouteInitial();
}

class RouteLoading extends RouteState {
  const RouteLoading();
}

class RouteLoaded extends RouteState {
  final MapRoute route;

  const RouteLoaded(this.route);
}

class RouteError extends RouteState {
  final String message;

  const RouteError(this.message);
}
