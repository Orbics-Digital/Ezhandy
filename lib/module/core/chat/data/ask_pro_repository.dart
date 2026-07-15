import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/chat/model/ask_pro_request_model.dart';

class AskProRepository {
  AskProRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<List<AskProRequestModel>> getRequests() async {
    final response = await _client.dio.get(ApiEndpoints.askProRequests);
    final envelope = ApiHelper.dataObject(response.data);
    final nested = envelope['data'];

    if (nested is! List) return [];

    return nested
        .whereType<Map>()
        .map((item) => AskProRequestModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<void> rejectRequest(String requestId) async {
    final response = await _client.dio.patch(
      ApiEndpoints.askProRejectRequest(requestId),
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Future<AskProAcceptResult> acceptRequest(String requestId) async {
    final response = await _client.dio.patch(
      ApiEndpoints.askProAcceptRequest(requestId),
    );

    if (response.data is! Map) {
      throw const FormatException('Invalid response');
    }

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }

    final envelope = ApiHelper.dataObject(response.data);
    final nested = envelope['data'];

    if (nested is Map) {
      return AskProAcceptResult.fromJson(
        Map<String, dynamic>.from(nested),
      );
    }

    return const AskProAcceptResult();
  }
}
