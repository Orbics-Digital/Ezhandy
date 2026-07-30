import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:flutter/foundation.dart';

class AppApiInterceptor extends Interceptor {
  AppApiInterceptor({
    required this.getToken,
    this.onUnauthorized,
  });

  final String? Function() getToken;
  final Future<void> Function()? onUnauthorized;
  bool _isHandlingUnauthorized = false;

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

    if (response.statusCode == 401) {
      _handleUnauthorized(response.requestOptions);
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

    if (err.response?.statusCode == 401) {
      _handleUnauthorized(err.requestOptions);
    }

    handler.next(err);
  }

  void _handleUnauthorized(RequestOptions requestOptions) {
    if (_shouldSkipUnauthorizedLogout(requestOptions.path)) return;
    if (_isHandlingUnauthorized) return;
    if (onUnauthorized == null) return;

    _isHandlingUnauthorized = true;
    onUnauthorized!().whenComplete(() {
      _isHandlingUnauthorized = false;
    });
  }

  bool _shouldSkipUnauthorizedLogout(String path) {
    final normalized = path.toLowerCase();
    return normalized.contains(ApiEndpoints.login) ||
        normalized.contains(ApiEndpoints.logout) ||
        normalized.contains(ApiEndpoints.registerProvider) ||
        normalized.contains(ApiEndpoints.forgotPassword) ||
        normalized.contains(ApiEndpoints.verifyOtp) ||
        normalized.contains(ApiEndpoints.verifyResetOtp) ||
        normalized.contains(ApiEndpoints.resetPassword) ||
        normalized.contains(ApiEndpoints.resendVerification);
  }
}
