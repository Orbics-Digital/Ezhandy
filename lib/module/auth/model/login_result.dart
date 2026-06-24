import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/auth/model/user_model.dart';

class LoginResult {
  final String token;
  final UserModel user;

  const LoginResult({required this.token, required this.user});

  factory LoginResult.fromResponse(dynamic responseData) {
    if (responseData is! Map) {
      throw const FormatException('Invalid login response');
    }

    final root = Map<String, dynamic>.from(responseData);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Login failed');
    }

    final data = root['data'];
    if (data is! Map) {
      throw const FormatException('Invalid login response');
    }

    final payload = Map<String, dynamic>.from(data);
    final token = payload['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw const FormatException('Login response did not include a token');
    }

    final userJson = payload['user_model'];
    if (userJson is! Map) {
      throw const FormatException('Login response did not include user data');
    }

    return LoginResult(
      token: token,
      user: UserModel.fromJson(Map<String, dynamic>.from(userJson)),
    );
  }
}
