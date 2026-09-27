import 'error_mapper.dart';
import 'exceptions/app_exception.dart';
import 'exceptions/server_exception.dart';
import 'exceptions/validation_exception.dart';
import 'exceptions/auth_exception.dart';
import 'exceptions/not_found_exception.dart';
import 'exceptions/network_exception.dart';
import 'exceptions/timeout_exception.dart';
import 'exceptions/model_exception.dart';
import 'failures/failure.dart';

class ErrorHandler {
  /// Converts any low-level error into an application-level [Failure].
  /// This should be called by the repository layer.
  static Failure handle(Object error, [StackTrace? stackTrace]) {
    // Note: Log the error and stackTrace to an external service (e.g., Crashlytics) here in a real app.
    return ErrorMapper.map(error);
  }

  /// Parses a backend JSON error response into an appropriate [AppException].
  /// Expected backend format:
  /// {
  ///   "success": false,
  ///   "code": "ERROR_CODE",
  ///   "message": "Human/debug message",
  ///   "details": {}
  /// }
  static AppException parseBackendError(dynamic responseData, {int? statusCode}) {
    if (responseData == null) {
      return ServerException(
        message: 'No response data received from backend',
        code: 'UNKNOWN_ERROR',
        statusCode: statusCode,
      );
    }

    Map<String, dynamic> response;
    
    if (responseData is Map<String, dynamic>) {
      response = responseData;
    } else {
      // Handle malformed JSON or unexpected response structure
      return ServerException(
        message: 'Invalid response format from server',
        code: 'MALFORMED_RESPONSE',
        statusCode: statusCode,
      );
    }

    final code = response['code'] as String?;
    final message = response['message'] as String? ?? 'An unexpected error occurred';
    final details = response['details'];

    // Map backend error codes to our defined exceptions
    switch (code) {
      case 'VALIDATION_ERROR':
        return ValidationException(
          message: message,
          code: code,
          validationErrors: details is Map<String, dynamic> ? details : null,
        );
      case 'UNAUTHORIZED':
      case 'FORBIDDEN':
        return AuthException(message: message, code: code);
      case 'NOT_FOUND':
        return NotFoundException(message: message, code: code);
      case 'NETWORK_ERROR':
        return NetworkException(message: message, code: code);
      case 'REQUEST_TIMEOUT':
        return TimeoutException(message: message, code: code);
      case 'AI_MODEL_UNAVAILABLE':
      case 'AI_MODEL_TIMEOUT':
      case 'AI_INVALID_RESPONSE':
      case 'AI_INVALID_INTENT':
      case 'AI_UNSUPPORTED_REQUEST':
      case 'AI_PROCESSING_ERROR':
      case 'RECOMMENDATION_SERVICE_ERROR':
        return ModelException(message: message, code: code);
      case 'SERVER_ERROR':
      default:
        return ServerException(
          message: message,
          code: code ?? 'UNKNOWN_ERROR',
          statusCode: statusCode,
        );
    }
  }
}
