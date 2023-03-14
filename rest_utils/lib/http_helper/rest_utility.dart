import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../models/base_service_model.dart';
import 'http_helper.dart';

enum Method { get, post, put, patch, delete }

extension MethodExtension on Method {
  String get value => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'][index];
}

Duration _connectTimeout = const Duration(milliseconds: 30000);
Duration _receiveTimeout = const Duration(milliseconds: 30000);
Duration _sendTimeout = const Duration(milliseconds: 10800);

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
      connectTimeout: connectTimeout ?? _connectTimeout,
      receiveTimeout: receiveTimeout ?? _receiveTimeout,
      sendTimeout: sendTimeout ?? _sendTimeout,
      baseUrl: baseUrl,
    );
    dio = Dio(options);

    /// Add default header interceptor
    dio.interceptors.add(DefaultHeaderInterceptor());

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
        options: _checkOptions(method.value, options),
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
    } on DioError catch (e) {
      print('Exception: ${ExceptionHandle.handleException(e)}');
      throw Exception(e.message);
    }
  }

  Options _checkOptions(String method, Options? options) {
    options ??= Options();
    options.method = method;
    return options;
  }
}
