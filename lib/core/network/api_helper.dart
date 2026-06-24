import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_constants.dart';

class ApiHelper {
  ApiHelper._();

  static Map<String, String> defaultHeaders() => {
        'Content-Type': ApiConstants.contentTypeJson,
        'Accept': ApiConstants.acceptJson,
      };

  static Map<String, String> authHeader(String token) => {
        'Authorization': 'Bearer $token',
      };

  static String errorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final message = responseMessage(Map<String, dynamic>.from(data));
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Unable to connect. Check your internet connection.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return error.message ?? 'Something went wrong.';
    }
  }

  static bool isSuccessResponse(Map<String, dynamic> json) {
    if (json['isSuccess'] == true || json['success'] == true) {
      return true;
    }
    if (json['isSuccess'] == false || json['success'] == false) {
      return false;
    }
    return json['statusCode'] == 200;
  }

  static String? responseMessage(Map<String, dynamic> json) {
    for (final key in ['message', 'error', 'detail']) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}
