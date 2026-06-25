import 'dart:convert';

import 'package:ezhandy_user/module/core/categories/model/category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesStorage {
  static const _categoriesKey = 'product_categories';

  Future<List<CategoryModel>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_categoriesKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map(
          (item) => CategoryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> saveCategories(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(categories.map((item) => item.toJson()).toList());
    await prefs.setString(_categoriesKey, encoded);
  }

  Future<void> clearCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoriesKey);
  }
}
