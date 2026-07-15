import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/auth/content/model/page_model.dart';

class PagesRepository {
  PagesRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<PageModel> getPageBySlug(String slug) async {
    final response = await _client.dio.get(ApiEndpoints.page(slug));
    final data = ApiHelper.dataObject(response.data);
    return PageModel.fromJson(data);
  }
}
