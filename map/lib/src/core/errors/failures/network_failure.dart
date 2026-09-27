import 'failure.dart';

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}
