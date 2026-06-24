import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/community/model/community_post_model.dart';

class CommunityRepository {
  CommunityRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<List<CommunityPostModel>> getPosts() async {
    final response = await _client.dio.get(ApiEndpoints.communityPosts);

    return ApiHelper.dataList(response.data)
        .map(CommunityPostModel.fromJson)
        .toList();
  }
}
