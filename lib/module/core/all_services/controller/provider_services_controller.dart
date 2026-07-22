import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/all_services/model/create_provider_service_params.dart';
import 'package:ezhandy_user/module/core/all_services/model/past_work_booking_model.dart';
import 'package:ezhandy_user/module/core/all_services/model/provider_service_model.dart';
import 'package:ezhandy_user/module/core/booking/data/bookings_repository.dart';
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
  final BookingsRepository _bookingsRepository = BookingsRepository();

  final RxList<ProviderServiceModel> providerServices =
      <ProviderServiceModel>[].obs;
  final RxList<PastWorkBookingModel> pastWorkBookings =
      <PastWorkBookingModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isCreateServiceLoading = false.obs;
  final RxBool isUpdateServiceLoading = false.obs;
  final RxBool isDeleteServiceLoading = false.obs;
  final RxBool isProviderServicesLoading = false.obs;
  final RxBool isPastWorkLoading = false.obs;

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

  ProviderServiceModel? getServiceById(String? serviceId) {
    final id = serviceId?.trim();
    if (id == null || id.isEmpty) return null;

    for (final service in providerServices) {
      if (service.id == id) return service;
    }
    return null;
  }

  Future<bool> updateService({
    required String serviceId,
    required CreateProviderServiceParams params,
  }) async {
    final id = serviceId.trim();
    if (id.isEmpty || isUpdateServiceLoading.value) return false;

    isUpdateServiceLoading.value = true;
    try {
      await _repository.updateService(serviceId: id, params: params);
      await refreshProviderServices();
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isUpdateServiceLoading.value = false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    final id = serviceId.trim();
    if (id.isEmpty || isDeleteServiceLoading.value) return false;

    isDeleteServiceLoading.value = true;
    try {
      await _repository.deleteService(id);
      providerServices.removeWhere((service) => service.id == id);
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isDeleteServiceLoading.value = false;
    }
  }

  Future<void> fetchPastWorkByService(String serviceId) async {
    final id = serviceId.trim();
    if (id.isEmpty || isPastWorkLoading.value) return;

    isPastWorkLoading.value = true;
    try {
      final bookings = await _bookingsRepository.getPastWorkByService(id);
      pastWorkBookings.assignAll(bookings);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isPastWorkLoading.value = false;
    }
  }

  Future<void> refreshPastWorkByService(String serviceId) async {
    final id = serviceId.trim();
    if (id.isEmpty) return;

    try {
      final bookings = await _bookingsRepository.getPastWorkByService(id);
      pastWorkBookings.assignAll(bookings);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  void clearPastWorkBookings() => pastWorkBookings.clear();
}
