import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_constants.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/core/network/api_interceptor.dart';
import 'package:get/get.dart';

class ApiClient extends GetxService {
  static ApiClient get i {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    return Get.find<ApiClient>();
  }

  late final Dio dio;
  String? _authToken;
  Future<void> Function()? onUnauthorized;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: ApiHelper.defaultHeaders(),
      ),
    );

    dio.interceptors.add(
      AppApiInterceptor(
        getToken: () => _authToken,
        onUnauthorized: () async {
          await onUnauthorized?.call();
        },
      ),
    );
  }

  void setAuthToken(String? token) => _authToken = token;

  void clearAuthToken() => _authToken = null;
}
