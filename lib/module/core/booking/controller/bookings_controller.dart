import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/booking/data/bookings_repository.dart';
import 'package:ezhandy_user/module/core/booking/model/provider_booking_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:get/get.dart';

class BookingsController extends GetxController {
  static BookingsController get i {
    if (!Get.isRegistered<BookingsController>()) {
      Get.put(BookingsController(), permanent: true);
    }
    return Get.find<BookingsController>();
  }

  final BookingsRepository _repository = BookingsRepository();

  final RxList<ProviderBookingModel> providerBookings =
      <ProviderBookingModel>[].obs;
  final RxBool isProviderBookingsLoading = false.obs;
  final RxString searchQuery = ''.obs;

  List<ProviderBookingModel> get filteredProviderBookings {
    final query = searchQuery.value.trim();
    if (query.isEmpty) return providerBookings.toList();

    return providerBookings
        .where(
          (booking) =>
              booking.bookingId?.toString().contains(query) ?? false,
        )
        .toList();
  }

  void setSearchQuery(String value) => searchQuery.value = value;

  Future<void> fetchProviderBookings() async {
    if (isProviderBookingsLoading.value) return;

    isProviderBookingsLoading.value = true;
    try {
      providerBookings.value = await _repository.getProviderBookings();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isProviderBookingsLoading.value = false;
    }
  }

  Future<void> refreshProviderBookings() async {
    try {
      providerBookings.value = await _repository.getProviderBookings();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }
}
