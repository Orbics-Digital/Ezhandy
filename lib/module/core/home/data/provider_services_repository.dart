import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';

class ProviderServicesRepository {
  ProviderServicesRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<bool> toggleQuickProvider({
    required String providerId,
    required bool isQuickProvider,
  }) async {
    final response = await _client.dio.patch(
      ApiEndpoints.quickProvider(providerId),
      data: {
        'isQuickProvider': isQuickProvider,
      },
    );

    final data = ApiHelper.dataObject(response.data);
    final value = data['isQuickProvider'];
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }
}
