import 'dart:convert';

import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/module/auth/model/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage extends GetxService {
  SessionStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static SessionStorage get i {
    if (!Get.isRegistered<SessionStorage>()) {
      Get.put(SessionStorage(), permanent: true);
    }
    return Get.find<SessionStorage>();
  }

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _rememberMeKey = 'remember_me';
  static const _rememberedEmailKey = 'remembered_email';
  static const _rememberedPasswordKey = 'remembered_password';

  final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  Future<SessionStorage> init() async {
    _prefs = await SharedPreferences.getInstance();
    final session = await load();
    if (session != null) {
      ApiClient.i.setAuthToken(session.token);
    }
    return this;
  }

  Future<void> save({required String token, required UserModel user}) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));
    ApiClient.i.setAuthToken(token);
  }

  Future<({String token, UserModel user})?> load() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;

    final userJson = _prefs?.getString(_userKey);
    if (userJson == null || userJson.isEmpty) {
      return (token: token, user: const UserModel());
    }

    return (
      token: token,
      user: UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>),
    );
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _tokenKey);
    await _prefs?.remove(_userKey);
    ApiClient.i.clearAuthToken();
  }

  Future<void> saveRememberedCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _rememberMeKey, value: 'true');
    await _secureStorage.write(key: _rememberedEmailKey, value: email.trim());
    await _secureStorage.write(key: _rememberedPasswordKey, value: password);
  }

  Future<({String email, String password})?> loadRememberedCredentials() async {
    final rememberMe = await _secureStorage.read(key: _rememberMeKey);
    if (rememberMe != 'true') return null;

    final email = await _secureStorage.read(key: _rememberedEmailKey);
    final password = await _secureStorage.read(key: _rememberedPasswordKey);
    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return null;
    }

    return (email: email, password: password);
  }

  Future<void> clearRememberedCredentials() async {
    await _secureStorage.delete(key: _rememberMeKey);
    await _secureStorage.delete(key: _rememberedEmailKey);
    await _secureStorage.delete(key: _rememberedPasswordKey);
  }
}
