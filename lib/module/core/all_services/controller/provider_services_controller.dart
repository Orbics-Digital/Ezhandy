import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/all_services/model/create_provider_service_params.dart';
import 'package:ezhandy_user/module/core/all_services/model/provider_service_model.dart';
import 'package:ezhandy_user/module/core/home/data/provider_services_repository.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:get/get.dart';

class ProviderServicesController extends GetxController {
  static ProviderServicesController get i {
    if (!Get.isRegistered<ProviderServicesController>()) {
      Get.put(ProviderServicesController(), permanent: true);
    }
    return Get.find<ProviderServicesController>();
  }

  final ProviderServicesRepository _repository = ProviderServicesRepository();

  final RxList<ProviderServiceModel> providerServices =
      <ProviderServiceModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isCreateServiceLoading = false.obs;
  final RxBool isProviderServicesLoading = false.obs;

  List<ProviderServiceModel> get filteredProviderServices {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return providerServices;

    return providerServices.where((service) {
      final title = service.title?.trim().toLowerCase() ?? '';
      return title.contains(query);
    }).toList();
  }

  void setSearchQuery(String value) => searchQuery.value = value;

  Future<void> fetchProviderServices() async {
    if (isProviderServicesLoading.value) return;

    isProviderServicesLoading.value = true;
    try {
      final services = await _repository.getProviderServices();
      providerServices.assignAll(services);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isProviderServicesLoading.value = false;
    }
  }

  Future<void> refreshProviderServices() async {
    try {
      final services = await _repository.getProviderServices();
      providerServices.assignAll(services);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<bool> createService(CreateProviderServiceParams params) async {
    if (isCreateServiceLoading.value) return false;

    isCreateServiceLoading.value = true;
    try {
      await _repository.createService(params);
      await refreshProviderServices();
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isCreateServiceLoading.value = false;
    }
  }
}
