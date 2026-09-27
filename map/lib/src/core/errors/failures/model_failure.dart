import 'failure.dart';

class ModelFailure extends Failure {
  const ModelFailure({
    required super.message,
    super.code,
  });
}
