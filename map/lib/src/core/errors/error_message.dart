import '../config/app_environment.dart';
import 'exceptions/app_exception.dart';
import 'exceptions/network_exception.dart';
import 'exceptions/timeout_exception.dart';
import 'exceptions/server_exception.dart';
import 'exceptions/validation_exception.dart';
import 'exceptions/not_found_exception.dart';
import 'exceptions/model_exception.dart';
import 'exceptions/auth_exception.dart';

class ErrorMessage {
  static String getMessage(AppException exception) {
    if (EnvironmentConfig.isDevelopment) {
      return exception.message;
    }

    if (exception is NetworkException) {
      return "Please check your internet connection.";
    } else if (exception is TimeoutException) {
      return "The request took too long. Please try again.";
    } else if (exception is ServerException) {
      return "Something went wrong on our side. Please try again.";
    } else if (exception is ValidationException) {
      return "Please check your input.";
    } else if (exception is NotFoundException) {
      return "The requested information was not found.";
    } else if (exception is AuthException) {
      return "You are not authorized to perform this action.";
    } else if (exception is ModelException) {
      if (exception.code == 'AI_MODEL_UNAVAILABLE') {
        return "Our AI service is temporarily unavailable.";
      }
      return "We could not process your request right now.";
    } else {
      return "Something went wrong. Please try again.";
    }
  }
}
