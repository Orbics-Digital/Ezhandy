import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';

class ContactUsRepository {
  ContactUsRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<void> submitQuery({
    required String subject,
    required String message,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.queries,
      data: {
        'subject': subject,
        'message': message,
      },
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(
        ApiHelper.responseMessage(root) ?? 'Failed to submit query',
      );
    }
  }
}
