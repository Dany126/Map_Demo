import 'app_exception.dart';

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.statusCode,
  });
}
