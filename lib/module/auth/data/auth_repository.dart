import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/auth/model/login_result.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    return LoginResult.fromResponse(response.data);
  }

  Future<void> logout() async {
    final response = await _client.dio.post(ApiEndpoints.logout);

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Logout failed');
    }
  }

  Future<void> forgotPassword({required String email}) async {
    final response = await _client.dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.verifyResetOtp,
      data: {
        'email': email,
        'otp': otp,
      },
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }
}
