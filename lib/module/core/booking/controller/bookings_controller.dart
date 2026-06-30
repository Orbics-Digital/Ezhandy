import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/booking/data/bookings_repository.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_status_enum.dart';
import 'package:ezhandy_user/module/core/booking/model/provider_booking_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
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
  final RxnInt selectedStatusId = RxnInt();

  String get selectedStatusLabel {
    final statusId = selectedStatusId.value;
    if (statusId == null) return AppStrings.all;
    return BookingStatusEnum.label(statusId);
  }

  List<ProviderBookingModel> get filteredProviderBookings {
    var result = providerBookings.toList();

    final statusId = selectedStatusId.value;
    if (statusId != null) {
      result = result.where((booking) => booking.status == statusId).toList();
    }

    final query = searchQuery.value.trim();
    if (query.isNotEmpty) {
      result = result
          .where(
            (booking) =>
                booking.bookingId?.toString().contains(query) ?? false,
          )
          .toList();
    }

    return result;
  }

  void setSearchQuery(String value) => searchQuery.value = value;

  void setStatusFilterByLabel(String? label) {
    selectedStatusId.value = BookingStatusEnum.idFromLabel(label);
  }

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
