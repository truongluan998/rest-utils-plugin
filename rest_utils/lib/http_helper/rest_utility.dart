import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../common/constants.dart';
import '../common/enum.dart';
import '../models/base_service_model.dart';
import 'handel_error.dart';


class RestUtil {
  late Dio dio;

  RestUtil(
    String baseUrl, {
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    List<Interceptor>? interceptors,
  }) {
    final options = BaseOptions(
      connectTimeout: connectTimeout ?? Constants.connectTimeout,
      receiveTimeout: receiveTimeout ?? Constants.receiveTimeout,
      sendTimeout: sendTimeout ?? Constants.sendTimeout,
      baseUrl: baseUrl,
    );
    dio = Dio(options);

    void addInterceptor(Interceptor interceptor) {
      dio.interceptors.add(interceptor);
    }

    if (interceptors != null && interceptors.isNotEmpty) {
      interceptors.forEach(addInterceptor);
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
  }) async {
    try {
      final getResponse = await dio.request(
        path,
        data: jsonEncode(request!.toJson()),
        queryParameters: queryParameters,
        options: _checkOptions(method.name, options),
        cancelToken: cancelToken,
      );
      final response = GetIt.instance.get<TResponse>();
      response.statusCode = getResponse.statusCode;
      response.errorCode = getResponse.statusCode.toString();
      response.errorMessage = getResponse.statusMessage;
      if (response.success) {
        if (response is StringResponseModel) {
          response.body = getResponse.data;
          return response;
        }
        final newResponse = response.fromJson(getResponse.data);
        newResponse.statusCode = response.statusCode;
        newResponse.errorCode = response.errorCode;
        return newResponse;
      }
      return response;
    } on DioException catch (e) {
      debugPrint('Exception: ${ExceptionHandle.fromDioError(e).toString()}');
      throw Exception(e.message);
    }
  }

  Options _checkOptions(String method, Options? options) {
    options ??= Options();
    options.method = method;
    return options;
  }
}
