import 'app_exception.dart';

class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}
