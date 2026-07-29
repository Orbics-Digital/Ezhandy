import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/booking/data/bookings_repository.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_detail_model.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_invoice_model.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_status_enum.dart';
import 'package:ezhandy_user/module/core/booking/model/provider_booking_model.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
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
  final RxString selectedBookingType = AppStrings.all.obs;

  static const List<String> bookingTypeFilterLabels = [
    AppStrings.all,
    AppStrings.urgent,
    AppStrings.scheduled,
  ];

  final Rxn<BookingDetailModel> bookingDetail = Rxn<BookingDetailModel>();
  final RxBool isBookingDetailLoading = false.obs;
  final RxBool isUpdatingBookingStatus = false.obs;
  final RxBool isAcceptingBooking = false.obs;
  final RxBool isRejectingBooking = false.obs;
  final Rxn<BookingInvoiceModel> bookingInvoice = Rxn<BookingInvoiceModel>();
  final RxBool isBookingInvoiceLoading = false.obs;
  final RxBool isAddingExtraTime = false.obs;

  String get selectedStatusLabel {
    final statusId = selectedStatusId.value;
    if (statusId == null) return AppStrings.all;
    return BookingStatusEnum.label(statusId);
  }

  List<ProviderBookingModel> get filteredProviderBookings {
    var result = providerBookings.toList();

    final statusId = selectedStatusId.value;
    if (statusId != null) {
      result = result
          .where(
            (booking) => BookingStatusEnum.matchesStatusFilter(
              booking.status,
              statusId,
            ),
          )
          .toList();
    }

    final type = selectedBookingType.value;
    if (type == AppStrings.urgent) {
      result = result.where((booking) => booking.isQuick).toList();
    } else if (type == AppStrings.scheduled) {
      result = result.where((booking) => !booking.isQuick).toList();
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

  List<ProviderBookingModel> get pendingHomeBookings {
    final pending = providerBookings
        .where((booking) => booking.status == BookingStatusEnum.Pending.id)
        .toList()
      ..sort((a, b) {
        final aDate = a.createdAt ??
            DateTime.tryParse(a.bookingDate ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ??
            DateTime.tryParse(b.bookingDate ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return pending.take(3).toList(growable: false);
  }

  void setSearchQuery(String value) => searchQuery.value = value;

  void setStatusFilterByLabel(String? label) {
    selectedStatusId.value = BookingStatusEnum.idFromLabel(label);
  }

  void setBookingTypeFilter(String? label) {
    selectedBookingType.value = label ?? AppStrings.all;
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

  Future<void> fetchBookingDetail(int id) async {
    if (isBookingDetailLoading.value) return;

    isBookingDetailLoading.value = true;
    try {
      final detail = await _repository.getBookingDetail(id);
      bookingDetail.value = detail;
      HomeController.i.jobStatus.value = detail.jobStatusLabel;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isBookingDetailLoading.value = false;
    }
  }

  void clearBookingDetail() {
    bookingDetail.value = null;
  }

  Future<void> fetchBookingInvoice(int bookingId) async {
    if (isBookingInvoiceLoading.value) return;

    isBookingInvoiceLoading.value = true;
    try {
      bookingInvoice.value = await _repository.getBookingInvoice(bookingId);
    } on DioException catch (e) {
      bookingInvoice.value = null;
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      bookingInvoice.value = null;
      AppDialogs.showToast(message: e.toString());
    } finally {
      isBookingInvoiceLoading.value = false;
    }
  }

  void clearBookingInvoice() {
    bookingInvoice.value = null;
  }

  Future<bool> addBookingExtraTime({
    required int bookingId,
    required String extraAmount,
    required String extraNote,
  }) async {
    if (isAddingExtraTime.value) return false;

    isAddingExtraTime.value = true;
    try {
      await _repository.addBookingExtraTime(
        bookingId: bookingId,
        extraAmount: extraAmount,
        extraNote: extraNote,
      );

      final detail = await _repository.getBookingDetail(bookingId);
      bookingDetail.value = detail;
      HomeController.i.jobStatus.value = detail.jobStatusLabel;
      await refreshProviderBookings();
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isAddingExtraTime.value = false;
    }
  }

  Future<bool> updateBookingStatus({
    required int bookingId,
    required int status,
    String? statusReason,
    bool forAccept = false,
    bool forReject = false,
  }) async {
    if (isUpdatingBookingStatus.value ||
        isAcceptingBooking.value ||
        isRejectingBooking.value) {
      return false;
    }

    void setLoading(bool value) {
      if (forAccept) {
        isAcceptingBooking.value = value;
      } else if (forReject) {
        isRejectingBooking.value = value;
      } else {
        isUpdatingBookingStatus.value = value;
      }
    }

    setLoading(true);
    try {
      await _repository.updateBookingStatus(
        bookingId: bookingId,
        status: status,
        statusReason: statusReason,
      );
      if (status == BookingStatusEnum.Completed.id) {
        await _repository.createBookingInvoice(bookingId);
      }

      final detail = await _repository.getBookingDetail(bookingId);
      bookingDetail.value = detail;
      HomeController.i.jobStatus.value = detail.jobStatusLabel;
      await refreshProviderBookings();
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> submitBeforeWorkAndStartJob({
    required int bookingId,
    required List<File> images,
  }) async {
    if (isUpdatingBookingStatus.value ||
        isAcceptingBooking.value ||
        isRejectingBooking.value) {
      return false;
    }

    if (images.isEmpty) {
      AppDialogs.showToast(message: AppStrings.pleaseUploadProductImage);
      return false;
    }

    isUpdatingBookingStatus.value = true;
    try {
      await _repository.uploadBeforeWork(
        bookingId: bookingId,
        images: images,
      );

      await _repository.updateBookingStatus(
        bookingId: bookingId,
        status: BookingStatusEnum.Started.id,
      );

      final detail = await _repository.getBookingDetail(bookingId);
      bookingDetail.value = detail;
      HomeController.i.jobStatus.value = detail.jobStatusLabel;
      await refreshProviderBookings();
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isUpdatingBookingStatus.value = false;
    }
  }

  Future<bool> submitAfterWorkAndEndJob({
    required int bookingId,
    required List<File> images,
  }) async {
    if (isUpdatingBookingStatus.value ||
        isAcceptingBooking.value ||
        isRejectingBooking.value) {
      return false;
    }

    if (images.isEmpty) {
      AppDialogs.showToast(message: AppStrings.pleaseUploadProductImage);
      return false;
    }

    isUpdatingBookingStatus.value = true;
    try {
      await _repository.uploadAfterWork(
        bookingId: bookingId,
        images: images,
      );

      await _repository.updateBookingStatus(
        bookingId: bookingId,
        status: BookingStatusEnum.Completed.id,
      );
      await _repository.createBookingInvoice(bookingId);

      final detail = await _repository.getBookingDetail(bookingId);
      bookingDetail.value = detail;
      HomeController.i.jobStatus.value = detail.jobStatusLabel;
      await refreshProviderBookings();
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isUpdatingBookingStatus.value = false;
    }
  }
}
