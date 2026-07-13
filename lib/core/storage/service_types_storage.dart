import 'dart:convert';

import 'package:ezhandy_user/module/core/service_types/model/service_type_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceTypesStorage {
  static const _serviceTypesKey = 'service_types';

  Future<List<ServiceTypeModel>> loadServiceTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_serviceTypesKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map(
          (item) => ServiceTypeModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> saveServiceTypes(List<ServiceTypeModel> serviceTypes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(serviceTypes.map((item) => item.toJson()).toList());
    await prefs.setString(_serviceTypesKey, encoded);
  }

  Future<void> clearServiceTypes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serviceTypesKey);
  }
}
