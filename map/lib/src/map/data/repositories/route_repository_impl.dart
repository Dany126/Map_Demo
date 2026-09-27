import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/errors/failures/failure.dart';
import '../../domain/entities/map_location.dart';
import '../../domain/entities/map_route.dart';
import '../../domain/repositories/route_repository.dart';
import '../models/route_model.dart';

class RouteRepositoryImpl implements RouteRepository {
  final Dio dio;

  RouteRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, MapRoute>> getRoute({
    required MapLocation start,
    required MapLocation destination,
  }) async {
    try {
      final response = await dio.get(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.lng},${start.lat};'
        '${destination.lng},${destination.lat}',
        queryParameters: {'overview': 'full', 'geometries': 'geojson'},
      );

      final route = RouteModel.fromJson(response.data as Map<String, dynamic>);

      return Right(route);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
