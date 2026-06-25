import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/core/storage/categories_storage.dart';
import 'package:ezhandy_user/module/core/categories/data/categories_repository.dart';
import 'package:ezhandy_user/module/core/categories/model/category_model.dart';
import 'package:get/get.dart';

class CategoriesController extends GetxController {
  static CategoriesController get i => Get.find<CategoriesController>();

  final CategoriesRepository _repository = CategoriesRepository();
  final CategoriesStorage _storage = CategoriesStorage();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  List<CategoryModel> get activeCategories =>
      categories.where((category) => category.isActive).toList();

  List<String> get categoryDropdownLabels => activeCategories
      .map((category) => category.displayName)
      .where((label) => label.isNotEmpty)
      .toList();

  List<CategoryModel> getCategoriesFromStorage() => categories.toList();

  CategoryModel? getCategoryById(String? id) {
    if (id == null || id.isEmpty) return null;

    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  CategoryModel? getCategoryByDisplayName(String? displayName) {
    if (displayName == null || displayName.isEmpty) return null;

    for (final category in activeCategories) {
      if (category.displayName == displayName) return category;
    }
    return null;
  }

  Future<void> initCategories() async {
    final cached = await _storage.loadCategories();
    if (cached.isNotEmpty) {
      categories.assignAll(cached);
    }

    try {
      final fetched = await _repository.getCategories();
      categories.assignAll(fetched);
      await _storage.saveCategories(fetched);
    } on DioException {
      // Keep cached categories when refresh fails.
    } catch (_) {
      // Keep cached categories when refresh fails.
    }
  }

  Future<void> refreshCategories() async {
    try {
      final fetched = await _repository.getCategories();
      categories.assignAll(fetched);
      await _storage.saveCategories(fetched);
    } on DioException catch (e) {
      throw Exception(ApiHelper.errorMessage(e));
    }
  }
}
