import 'dart:io';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String errorCode;
  final String message;

  const Failure(this.errorCode, this.message);

  @override
  List<Object> get props => [errorCode, message];
}

class GeneralFailure extends Failure {
  const GeneralFailure(String errorCode, String message) : super(errorCode, message);
}

class ApiFailure extends Failure {
  final int statusCode;

  const ApiFailure(this.statusCode, String errorCode, String message) : super(errorCode, message);

  factory ApiFailure.fromJson(Map<String, dynamic> json, int statusCode) =>
      ApiFailure(statusCode, json['errorCode'] as String? ?? '', '');
}

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

  static final Map<int, ApiFailure> _errorMap = <int, ApiFailure>{
    unauthorized: const ApiFailure(unauthorized, 'un_authorized', 'Unauthorized'),
    netError: const ApiFailure(netError, 'network_error', 'Network Error'),
    parseError: const ApiFailure(parseError, 'parse_error', 'Parse Error'),
    socketError: const ApiFailure(socketError, 'socket_error', 'Socket Error'),
    httpError: const ApiFailure(httpError, 'http_error', 'Http Error'),
    connectTimeoutError: const ApiFailure(connectTimeoutError, 'connect_timeout', 'Xonnect Timeout'),
    sendTimeoutError: const ApiFailure(sendTimeoutError, 'sent_timeout', 'Send Timeout Error'),
    receiveTimeoutError: const ApiFailure(receiveTimeoutError, 'receive_timeout', 'Receive Timeout'),
    cancelError: const ApiFailure(cancelError, 'cancel_error', 'Cancel Error'),
    internalServerError: const ApiFailure(internalServerError, 'internal_server_error', 'Internal Server Error'),
    forbidden: const ApiFailure(forbidden, 'forbidden', 'Forbidden'),
    notFound: const ApiFailure(notFound, 'not_found', 'Not Found'),
    badGateway: const ApiFailure(badGateway, 'bad_gateway', 'Bad Gateway'),
    serviceUnavailable: const ApiFailure(serviceUnavailable, 'service_unavailable', 'Service Unavailable'),
    gatewayTimeout: const ApiFailure(gatewayTimeout, 'gateway_timeout', 'Gateway Timeout')
  };

  static ApiFailure handleException(error) {
    if (error is DioError) {
      if (error.response?.statusCode == 0) {
        return _handleException(error.error);
      } else {
        return _errorMap[error.response?.statusCode]!;
      }
    } else {
      return _handleException(error);
    }
  }

  static ApiFailure _handleException(error) {
    var errorCode = unknownError;
    if (error is SocketException) {
      errorCode = socketError;
    }
    if (error is HttpException) {
      errorCode = httpError;
    }
    if (error is FormatException) {
      errorCode = parseError;
    }
    return _errorMap[errorCode] ?? ApiFailure(errorCode, 'unknown_error', 'Unknown Error');
  }
}

extension DioErrorTypeExtension on DioErrorType {
  int get errorCode => [
        ExceptionHandle.connectTimeoutError,
        ExceptionHandle.sendTimeoutError,
        ExceptionHandle.receiveTimeoutError,
        0,
        ExceptionHandle.cancelError,
        0,
      ][index];
}
