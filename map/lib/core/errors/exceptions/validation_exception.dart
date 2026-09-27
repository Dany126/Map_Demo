import 'app_exception.dart';

class ValidationException extends AppException {
  final Map<String, dynamic>? validationErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.validationErrors,
  });
}
