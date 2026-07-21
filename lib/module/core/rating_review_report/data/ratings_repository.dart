import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/rating_review_report/model/provider_rating_model.dart';

class RatingsRepository {
  RatingsRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<List<ProviderRatingModel>> getProviderRatings(String providerId) async {
    final response = await _client.dio.get(
      ApiEndpoints.providerRatings(providerId),
    );

    return ApiHelper.dataList(response.data)
        .map(ProviderRatingModel.fromJson)
        .toList();
  }
}
