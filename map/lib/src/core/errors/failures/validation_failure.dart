import 'failure.dart';

class ValidationFailure extends Failure {
  final Map<String, dynamic>? validationErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.validationErrors,
  });
}
