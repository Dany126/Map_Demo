import 'package:dartz/dartz.dart';
import 'package:map/core/errors/failures/failure.dart';

abstract class Usecase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class UsecaseWithoutParams<Type> {
  Future<Either<Failure, Type>> call();
}

abstract class StreamUsecaseWithoutParams<Type> {
  Stream<Type> call();
}
