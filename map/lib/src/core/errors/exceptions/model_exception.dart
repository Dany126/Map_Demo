import 'app_exception.dart';

class ModelException extends AppException {
  const ModelException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}
