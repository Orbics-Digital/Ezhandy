import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/service_types/model/service_type_model.dart';

class ServiceTypesRepository {
  ServiceTypesRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<List<ServiceTypeModel>> getServiceTypes() async {
    final response = await _client.dio.get(ApiEndpoints.serviceTypes);

    return ApiHelper.dataList(response.data)
        .map(ServiceTypeModel.fromJson)
        .toList();
  }
}
