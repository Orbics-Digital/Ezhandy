import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/categories/model/category_model.dart';

class CategoriesRepository {
  CategoriesRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.dio.get(ApiEndpoints.categories);

    return ApiHelper.dataList(response.data)
        .map(CategoryModel.fromJson)
        .toList();
  }
}
