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
}
