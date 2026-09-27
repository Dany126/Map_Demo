import 'exceptions/app_exception.dart';
import 'exceptions/server_exception.dart';
import 'exceptions/network_exception.dart';
import 'exceptions/timeout_exception.dart';
import 'exceptions/cache_exception.dart';
import 'exceptions/auth_exception.dart';
import 'exceptions/validation_exception.dart';
import 'exceptions/not_found_exception.dart';
import 'exceptions/model_exception.dart';

import 'failures/failure.dart';
import 'failures/server_failure.dart';
import 'failures/network_failure.dart';
import 'failures/timeout_failure.dart';
import 'failures/cache_failure.dart';
import 'failures/auth_failure.dart';
import 'failures/validation_failure.dart';
import 'failures/not_found_failure.dart';
import 'failures/model_failure.dart';

import 'error_message.dart';

class ErrorMapper {
  static Failure map(Object error) {
    if (error is AppException) {
      final safeMessage = ErrorMessage.getMessage(error);

      if (error is ServerException) {
        return ServerFailure(
          message: safeMessage,
          code: error.code,
          statusCode: error.statusCode,
        );
      } else if (error is NetworkException) {
        return NetworkFailure(message: safeMessage, code: error.code);
      } else if (error is TimeoutException) {
        return TimeoutFailure(message: safeMessage, code: error.code);
      } else if (error is CacheException) {
        return CacheFailure(message: safeMessage, code: error.code);
      } else if (error is AuthException) {
        return AuthFailure(message: safeMessage, code: error.code);
      } else if (error is ValidationException) {
        return ValidationFailure(
          message: safeMessage,
          code: error.code,
          validationErrors: error.validationErrors,
        );
      } else if (error is NotFoundException) {
        return NotFoundFailure(message: safeMessage, code: error.code);
      } else if (error is ModelException) {
        return ModelFailure(message: safeMessage, code: error.code);
      }
    }

    // Fallback for unknown errors that are not AppExceptions
    return const ServerFailure(
      message: "Something went wrong. Please try again.",
      code: "UNKNOWN_ERROR",
    );
  }
}
