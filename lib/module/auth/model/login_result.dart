import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/auth/model/user_model.dart';

class LoginResult {
  final String? token;
  final UserModel? user;
  final bool isEmailVerified;
  final String? message;

  const LoginResult({
    this.token,
    this.user,
    this.isEmailVerified = true,
    this.message,
  });

  bool get requiresEmailVerification => !isEmailVerified;

  factory LoginResult.fromResponse(dynamic responseData) {
    if (responseData is! Map) {
      throw const FormatException('Invalid login response');
    }

    final root = Map<String, dynamic>.from(responseData);
    final data = root['data'];
    final payload = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};

    final statusCode = root['statusCode'];
    final isEmailVerified = _readBool(
      payload['isEmailVerified'] ?? true,
    );

    // Unverified email: backend may return 499 with null token/user_model.
    if (statusCode == 499 ||
        (payload.containsKey('isEmailVerified') && !isEmailVerified)) {
      return LoginResult(
        isEmailVerified: false,
        message: ApiHelper.responseMessage(root),
      );
    }

    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Login failed');
    }

    final token = payload['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw const FormatException('Login response did not include a token');
    }

    final userJson = payload['user_model'];
    if (userJson is! Map) {
      throw const FormatException('Login response did not include user data');
    }

    final userMap = Map<String, dynamic>.from(userJson);
    return LoginResult(
      token: token,
      user: UserModel.fromJson(userMap).copyWith(
        isEmailVerified: _readBool(
          payload['isEmailVerified'] ?? userMap['isEmailVerified'],
        ),
        isOtpVerified: _readBool(
          payload['isOtpVerified'] ?? userMap['isOtpVerified'],
        ),
        isOtpExpired: _readBool(
          payload['isOtpExpired'] ?? userMap['isOtpExpired'],
        ),
      ),
      isEmailVerified: true,
      message: ApiHelper.responseMessage(root),
    );
  }
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}
