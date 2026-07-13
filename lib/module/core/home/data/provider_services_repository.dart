import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_constants.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/all_services/model/create_provider_service_params.dart';
import 'package:ezhandy_user/module/core/all_services/model/provider_service_model.dart';

class ProviderServicesRepository {
  ProviderServicesRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<void> createService(CreateProviderServiceParams params) async {
    final formData = FormData.fromMap({
      'title': params.title,
      'description': params.description,
      'visitCharges': params.visitCharges,
      'hourlyRate': params.hourlyRate,
      'radius': params.radius,
      'serviceTypeId': params.serviceTypeId,
      'isQuickService': params.isQuickService,
      'isServiceActive': params.isServiceActive,
      'timeSlots': jsonEncode(params.timeSlots),
      'calendar': jsonEncode(params.calendar),
      if (params.isQuickService &&
          params.quickServiceExtraFee != null &&
          params.quickServiceExtraFee!.isNotEmpty)
        'quickServiceExtraFee': params.quickServiceExtraFee,
    });

    final fileName = params.image.path.split(Platform.pathSeparator).last;
    formData.files.add(
      MapEntry(
        'image',
        await MultipartFile.fromFile(
          params.image.path,
          filename: fileName,
        ),
      ),
    );

    final response = await _client.dio.post(
      ApiEndpoints.providerServices,
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        headers: {'Accept': ApiConstants.acceptJson},
      ),
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Future<List<ProviderServiceModel>> getProviderServices() async {
    final response = await _client.dio.get(ApiEndpoints.providerServicesList);

    return ApiHelper.dataList(response.data)
        .map(ProviderServiceModel.fromJson)
        .toList();
  }

  Future<void> deleteService(String serviceId) async {
    final response =
        await _client.dio.delete(ApiEndpoints.providerService(serviceId));
    final data = response.data;

    if (data is! Map) return;

    final root = Map<String, dynamic>.from(data);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

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
