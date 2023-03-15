import 'package:dio/dio.dart';

class ExceptionHandle {
  static const int success = 200;
  static const int successNotContent = 204;
  static const int multipleChoice = 300;
  static const int notModified = 304;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int badRequest = 400;
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;

  static const int netError = 1000;
  static const int parseError = 1001;
  static const int socketError = 1002;
  static const int httpError = 1003;
  static const int connectTimeoutError = 1004;
  static const int sendTimeoutError = 1005;
  static const int receiveTimeoutError = 1006;
  static const int cancelError = 1007;
  static const int unknownError = 9999;

  /// TODO: Implement in future
  static String handleException(error) {
    if (error is DioError) {
      if (error.response?.statusCode == 0) {
        return '';
      } else {
        return '';
      }
    } else {
      return '';
    }
  }
}
