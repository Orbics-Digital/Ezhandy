import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/chat/model/chat_history_message_model.dart';
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

  Future<List<ChatHistoryMessageModel>> getChatHistory(
    String chatId, {
    int limit = 30,
    int offset = 0,
  }) async {
    final response = await _client.dio.get(
      ApiEndpoints.chatHistory(chatId),
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    return ApiHelper.dataList(response.data)
        .map(ChatHistoryMessageModel.fromJson)
        .toList();
  }

  Future<String> findOrCreateChat({required String otherUserId}) async {
    final response = await _client.dio.post(
      ApiEndpoints.findOrCreateChat,
      data: {'otherUserId': otherUserId},
    );

    final data = ApiHelper.dataObject(response.data);
    final chatId = data['chatId']?.toString().trim();
    if (chatId == null || chatId.isEmpty) {
      throw Exception('Chat not found');
    }

    return chatId;
  }
}
