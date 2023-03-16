import 'package:dio/dio.dart';

class ExceptionHandle implements Exception {
  var message = '';

  ExceptionHandle.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.cancel:
        message = 'Request to API server was cancelled';
        break;
      case DioErrorType.connectionTimeout:
        message = 'Connection timeout with API server';
        break;
      case DioErrorType.connectionError:
        message = 'Connection to API server failed due to internet connection';
        break;
      case DioErrorType.receiveTimeout:
        message = 'Receive timeout in connection with API server';
        break;
      case DioErrorType.badResponse:
        message = _handleError(dioError.response?.statusCode ?? 0, dioError.response?.data);
        break;
      case DioErrorType.sendTimeout:
        message = 'Send timeout in connection with API server';
        break;
      case DioErrorType.badCertificate:
        message = 'Bad certificate';
        break;
      case DioErrorType.unknown:
        message = 'Something went wrong';
        break;
      default:
        message = 'Something went wrong';
        break;
    }
  }

  String _handleError(int statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 404:
        return error["message"];
      case 500:
        return 'Internal server error';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message;
}
