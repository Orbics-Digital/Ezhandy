import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/core/storage/service_types_storage.dart';
import 'package:ezhandy_user/module/core/service_types/data/service_types_repository.dart';
import 'package:ezhandy_user/module/core/service_types/model/service_type_model.dart';
import 'package:get/get.dart';

class ServiceTypesController extends GetxController {
  static ServiceTypesController get i => Get.find<ServiceTypesController>();

  final ServiceTypesRepository _repository = ServiceTypesRepository();
  final ServiceTypesStorage _storage = ServiceTypesStorage();

  final RxList<ServiceTypeModel> serviceTypes = <ServiceTypeModel>[].obs;

  List<ServiceTypeModel> get activeServiceTypes =>
      serviceTypes.where((type) => type.isActive).toList();

  List<String> get serviceTypeDropdownLabels => activeServiceTypes
      .map((type) => type.displayName)
      .where((label) => label.isNotEmpty)
      .toList();

  List<ServiceTypeModel> getServiceTypesFromStorage() => serviceTypes.toList();

  ServiceTypeModel? getServiceTypeById(String? id) {
    if (id == null || id.isEmpty) return null;

    for (final type in serviceTypes) {
      if (type.id == id) return type;
    }
    return null;
  }

  ServiceTypeModel? getServiceTypeByDisplayName(String? displayName) {
    if (displayName == null || displayName.isEmpty) return null;

    for (final type in activeServiceTypes) {
      if (type.displayName == displayName) return type;
    }
    return null;
  }

  Future<void> initServiceTypes() async {
    final cached = await _storage.loadServiceTypes();
    if (cached.isNotEmpty) {
      serviceTypes.assignAll(cached);
    }

    try {
      final fetched = await _repository.getServiceTypes();
      serviceTypes.assignAll(fetched);
      await _storage.saveServiceTypes(fetched);
    } on DioException {
      // Keep cached service types when refresh fails.
    } catch (_) {
      // Keep cached service types when refresh fails.
    }
  }

  Future<void> refreshServiceTypes() async {
    try {
      final fetched = await _repository.getServiceTypes();
      serviceTypes.assignAll(fetched);
      await _storage.saveServiceTypes(fetched);
    } on DioException catch (e) {
      throw Exception(ApiHelper.errorMessage(e));
    }
  }
}
