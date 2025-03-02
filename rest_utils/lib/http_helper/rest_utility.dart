import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../common/constants.dart';
import '../common/enum.dart';
import '../models/base_service_model.dart';
import 'handel_error.dart';

class RestUtil {
  final Dio dio;

  RestUtil(
      String baseUrl, {
        Duration? connectTimeout,
        Duration? receiveTimeout,
        Duration? sendTimeout,
        List<Interceptor>? interceptors,
        Dio? dioInstance,
      }) : dio = dioInstance ?? Dio(
    BaseOptions(
      connectTimeout: connectTimeout ?? Constants.connectTimeout,
      receiveTimeout: receiveTimeout ?? Constants.receiveTimeout,
      sendTimeout: sendTimeout ?? Constants.sendTimeout,
      baseUrl: baseUrl,
    ),
  ) {
    if (interceptors != null && interceptors.isNotEmpty) {
      dio.interceptors.addAll(interceptors);
    }
  }

  Future<TResponse> request<TRequest extends BaseRequestModel,
  TResponse extends BaseResponseModel>(
      String path,
      Method method, {
        TRequest? request,
        Map<String, dynamic>? queryParameters,
        CancelToken? cancelToken,
        Options? options,
        required TResponse Function(Map<String, dynamic>) fromJson,
      }) async {
    try {
      final requestData = request != null ? jsonEncode(request.toJson()) : null;

      final response = await dio.request(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: _checkOptions(method.name, options),
        cancelToken: cancelToken,
      );

      final responseModel = fromJson(response.data)
        ..statusCode = response.statusCode
        ..errorCode = response.statusCode.toString()
        ..errorMessage = response.statusMessage;

      return responseModel;
    } on DioException catch (e) {
      final errorDetails = ExceptionHandle.fromDioError(e);
      debugPrint(errorDetails.toString());

      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: errorDetails.message,
      );
    }
  }

  Options _checkOptions(String method, Options? options) {
    return (options ?? Options())..method = method;
  }
}