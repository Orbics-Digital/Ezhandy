import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:flutter/foundation.dart';

class AppApiInterceptor extends Interceptor {
  AppApiInterceptor({required this.getToken});

  final String? Function() getToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll(ApiHelper.defaultHeaders());

    final token = getToken();
    if (token != null && token.isNotEmpty) {
      options.headers.addAll(ApiHelper.authHeader(token));
    }

    if (kDebugMode) {
      log('[API] ${options.method} ${options.uri}');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log('[API] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        '[API] ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.uri} -> ${ApiHelper.errorMessage(err)}',
      );
    }
    handler.next(err);
  }
}
