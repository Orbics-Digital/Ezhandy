import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_constants.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/auth/model/login_result.dart';
import 'package:ezhandy_user/module/auth/model/register_provider_params.dart';
import 'package:ezhandy_user/module/auth/model/user_model.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<LoginResult> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        },
      );

      return LoginResult.fromResponse(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        final root = Map<String, dynamic>.from(data);
        final payload = root['data'];
        final statusCode = root['statusCode'];
        final isEmailVerified = payload is Map
            ? payload['isEmailVerified']
            : null;

        if (statusCode == 499 || isEmailVerified == false) {
          return LoginResult.fromResponse(data);
        }
      }
      rethrow;
    }
  }

  Future<void> registerProvider(RegisterProviderParams params) async {
    final formData = FormData.fromMap({
      'fullName': params.fullName,
      'email': params.email,
      if (params.mobileNumber != null && params.mobileNumber!.isNotEmpty)
        'mobileNumber': params.mobileNumber,
      'languageId': params.languageId,
      'gender': params.gender,
      'password': params.password,
      'address': params.address,
      'aboutUs': params.aboutUs,
      'experience': params.experience,
      if (params.referredBy != null && params.referredBy!.trim().isNotEmpty)
        'referredBy': params.referredBy!.trim(),
      'institutionNames': jsonEncode(params.institutionNames),
      'certificationTitles': jsonEncode(params.certificationTitles),
    });

    if (params.profileImage != null) {
      final file = params.profileImage!;
      formData.files.add(
        MapEntry(
          'profileImage',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    for (final image in params.certificationImages) {
      formData.files.add(
        MapEntry(
          'certificationImages',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    final response = await _client.dio.post(
      ApiEndpoints.registerProvider,
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        headers: {'Accept': ApiConstants.acceptJson},
      ),
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Registration failed');
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.verifyOtp,
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

  Future<void> resendVerification({required String email}) async {
    final response = await _client.dio.post(
      ApiEndpoints.resendVerification,
      data: {'email': email},
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Future<void> logout() async {
    final response = await _client.dio.post(ApiEndpoints.logout);

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Logout failed');
    }
  }

  Future<void> deleteAccount() async {
    final response = await _client.dio.delete(ApiEndpoints.deleteAccount);

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(
        ApiHelper.responseMessage(root) ?? 'Failed to delete account',
      );
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

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String gender,
    required String address,
    required String? mobileNumber,
    required int languageId,
    required String aboutUs,
    required int? experience,
    File? profileImage,
  }) async {
    final formData = FormData.fromMap({
      'fullName': fullName,
      'gender': gender,
      'address': address,
      if (mobileNumber != null && mobileNumber.isNotEmpty)
        'mobileNumber': mobileNumber,
      'languageId': languageId,
      'aboutUs': aboutUs,
      if (experience != null) 'experience': experience,
    });

    if (profileImage != null) {
      formData.files.add(
        MapEntry(
          'profileImage',
          await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    log(
      '[UpdateProfile] fields: '
      '${{for (final entry in formData.fields) entry.key: entry.value}}, '
      'files: ${formData.files.map((entry) => entry.key).toList()}',
    );

    final response = await _client.dio.patch(
      ApiEndpoints.updateProfile,
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        headers: {'Accept': ApiConstants.acceptJson},
      ),
    );

    final data = ApiHelper.dataObject(response.data);
    final userModel = data['user_model'];
    if (userModel is Map) {
      return Map<String, dynamic>.from(userModel);
    }
    return data;
  }

  Future<UserModel> getProfileDetails() async {
    final response = await _client.dio.get(ApiEndpoints.profileDetails);
    final data = ApiHelper.dataObject(response.data);
    return UserModel.fromJson(data);
  }

  Future<void> addCertification({
    required String institutionName,
    required String certificationTitle,
    required File certificationImage,
  }) async {
    final formData = FormData.fromMap({
      'institutionName': institutionName,
      'certificationTitle': certificationTitle,
    });

    formData.files.add(
      MapEntry(
        'certificationImage',
        await MultipartFile.fromFile(
          certificationImage.path,
          filename: certificationImage.path.split(Platform.pathSeparator).last,
        ),
      ),
    );

    final response = await _client.dio.post(
      ApiEndpoints.certifications,
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        headers: {'Accept': ApiConstants.acceptJson},
      ),
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(
        ApiHelper.responseMessage(root) ?? 'Failed to add certification',
      );
    }
  }

  Future<void> updateCertification({
    required String certificationId,
    required String institutionName,
    required String certificationTitle,
    File? certificationImage,
  }) async {
    final formData = FormData.fromMap({
      'institutionName': institutionName,
      'certificationTitle': certificationTitle,
    });

    if (certificationImage != null) {
      formData.files.add(
        MapEntry(
          'certificationImage',
          await MultipartFile.fromFile(
            certificationImage.path,
            filename:
                certificationImage.path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    final response = await _client.dio.patch(
      ApiEndpoints.certification(certificationId),
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        headers: {'Accept': ApiConstants.acceptJson},
      ),
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(
        ApiHelper.responseMessage(root) ?? 'Failed to update certification',
      );
    }
  }

  Future<void> deleteCertification(String certificationId) async {
    final response = await _client.dio.delete(
      ApiEndpoints.certification(certificationId),
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(
        ApiHelper.responseMessage(root) ?? 'Failed to delete certification',
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }
}
