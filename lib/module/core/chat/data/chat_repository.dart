import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/chat/model/my_chat_model.dart';

class ChatRepository {
  ChatRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<List<MyChatModel>> getMyChats() async {
    final response = await _client.dio.get(ApiEndpoints.myChats);

    return ApiHelper.dataList(response.data)
        .map(MyChatModel.fromJson)
        .toList();
  }
}
