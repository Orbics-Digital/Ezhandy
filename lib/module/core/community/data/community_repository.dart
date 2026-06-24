import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/community/model/community_comment_model.dart';
import 'package:ezhandy_user/module/core/community/model/community_post_model.dart';
import 'package:ezhandy_user/module/core/community/model/community_reactions_model.dart';

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

  Future<List<CommunityCommentModel>> getComments(String postId) async {
    final response = await _client.dio.get(ApiEndpoints.postComments(postId));

    return ApiHelper.dataList(response.data)
        .map(CommunityCommentModel.fromJson)
        .toList();
  }

  Future<CommunityCommentModel> addComment({
    required String postId,
    required String text,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.postComments(postId),
      data: {'text': text},
    );

    return CommunityCommentModel.fromJson(
      ApiHelper.dataObject(response.data),
    );
  }

  Future<Map<String, dynamic>> addReaction({
    required String postId,
    required String reactionType,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.postReactions(postId),
      data: {'reactionType': reactionType},
    );

    return ApiHelper.dataObject(response.data);
  }

  Future<CommunityReactionsData> getReactions(String postId) async {
    final response = await _client.dio.get(ApiEndpoints.postReactions(postId));
    final data = ApiHelper.dataObject(response.data);

    final countsJson = data['counts'];
    final reactionsJson = data['reactions'];

    return CommunityReactionsData(
      counts: countsJson is Map
          ? CommunityReactionsCountsModel.fromJson(
              Map<String, dynamic>.from(countsJson),
            )
          : const CommunityReactionsCountsModel(),
      reactions: reactionsJson is List
          ? reactionsJson
              .whereType<Map>()
              .map(
                (item) => CommunityReactionItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }
}
