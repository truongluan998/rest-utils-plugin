import 'package:dio/dio.dart';

class ExceptionHandle implements Exception {
  final String message;
  final int? statusCode;

  ExceptionHandle({required this.message, this.statusCode});

  factory ExceptionHandle.fromDioError(DioException dioError) {
    String errorMessage;
    int? statusCode;

    switch (dioError.type) {
      case DioExceptionType.cancel:
        errorMessage = 'Request to API server was cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout with API server';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Failed to connect to API server. Check your internet connection';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout in connection with API server';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout in connection with API server';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Bad certificate';
        break;
      case DioExceptionType.badResponse:
        statusCode = dioError.response?.statusCode;
        errorMessage = _handleError(statusCode, dioError.response?.data);
        break;
      case DioExceptionType.unknown:
      default:
        errorMessage = 'An unexpected error occurred. Please try again later.';
        break;
    }

    return ExceptionHandle(message: errorMessage, statusCode: statusCode);
  }

  static String _handleError(int? statusCode, dynamic error) {
    if (error == null || error is! Map<String, dynamic>) {
      return 'Unexpected server response';
    }

    switch (statusCode) {
      case 400:
        return error["message"] ?? 'Bad request';
      case 401:
        return 'Unauthorized request. Please check your credentials.';
      case 403:
        return 'Forbidden request. You do not have permission to access this resource.';
      case 404:
        return error["message"] ?? 'Requested resource not found';
      case 422:
        return error["message"] ?? 'Invalid input data';
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        return error["message"] ?? 'An unexpected error occurred';
    }
  }

  @override
  String toString() => 'Error $statusCode: $message';
}
