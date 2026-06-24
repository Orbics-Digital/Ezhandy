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
}
