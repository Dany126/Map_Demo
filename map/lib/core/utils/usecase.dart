import 'package:dartz/dartz.dart';
import 'package:map/core/errors/failures/failure.dart';

abstract class Usecase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

abstract class UsecaseWithoutParams<T> {
  Future<Either<Failure, T>> call();
}

abstract class StreamUsecaseWithoutParams<T> {
  Stream<T> call();
}
