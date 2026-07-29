import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_constants.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_detail_model.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_invoice_model.dart';
import 'package:ezhandy_user/module/core/booking/model/provider_booking_model.dart';
import 'package:ezhandy_user/module/core/all_services/model/past_work_booking_model.dart';

class BookingsRepository {
  BookingsRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<List<ProviderBookingModel>> getProviderBookings() async {
    final response = await _client.dio.get(ApiEndpoints.providerBookings);

    return ApiHelper.dataList(response.data)
        .map(ProviderBookingModel.fromJson)
        .toList();
  }

  Future<BookingDetailModel> getBookingDetail(int id) async {
    final response = await _client.dio.get(ApiEndpoints.bookingDetail('$id'));
    final data = ApiHelper.dataObject(response.data);
    return BookingDetailModel.fromJson(data);
  }

  Future<List<PastWorkBookingModel>> getPastWorkByService(String serviceId) async {
    final response = await _client.dio.get(
      ApiEndpoints.pastWorkByService(serviceId.trim()),
    );

    return ApiHelper.dataList(response.data)
        .map(PastWorkBookingModel.fromJson)
        .toList();
  }

  Future<void> updateBookingStatus({
    required int bookingId,
    required int status,
    String? statusReason,
  }) async {
    final body = <String, dynamic>{
      'bookingId': bookingId,
      'status': status,
    };

    if (statusReason != null && statusReason.trim().isNotEmpty) {
      body['statusReason'] = statusReason.trim();
    }

    final response = await _client.dio.patch(
      ApiEndpoints.updateBookingStatus,
      data: body,
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Future<void> createBookingInvoice(int bookingId) async {
    final response = await _client.dio.post(
      ApiEndpoints.bookingInvoice(bookingId),
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Future<BookingInvoiceModel> getBookingInvoice(int bookingId) async {
    final response = await _client.dio.get(
      ApiEndpoints.bookingInvoice(bookingId),
    );
    final data = ApiHelper.dataObject(response.data);
    return BookingInvoiceModel.fromJson(data);
  }

  Future<void> addBookingExtraTime({
    required int bookingId,
    required String extraAmount,
    required String extraNote,
  }) async {
    final response = await _client.dio.patch(
      ApiEndpoints.bookingExtraTime(bookingId),
      data: {
        'extraAmount': extraAmount,
        'extraNote': extraNote,
      },
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Future<void> uploadBeforeWork({
    required int bookingId,
    required List<File> images,
  }) async {
    await _uploadWorkImages(
      endpoint: ApiEndpoints.beforeWork,
      bookingId: bookingId,
      images: images,
    );
  }

  Future<void> uploadAfterWork({
    required int bookingId,
    required List<File> images,
  }) async {
    await _uploadWorkImages(
      endpoint: ApiEndpoints.afterWork,
      bookingId: bookingId,
      images: images,
    );
  }

  Future<void> _uploadWorkImages({
    required String endpoint,
    required int bookingId,
    required List<File> images,
  }) async {
    final formData = FormData.fromMap({
      'bookingId': bookingId,
    });

    for (final image in images) {
      final fileName = image.path.split(Platform.pathSeparator).last;
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            image.path,
            filename: fileName,
          ),
        ),
      );
    }

    final response = await _client.dio.post(
      endpoint,
      data: formData,
      options: _multipartOptions(),
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Options _multipartOptions() {
    return Options(
      contentType: Headers.multipartFormDataContentType,
      headers: {'Accept': ApiConstants.acceptJson},
    );
  }
}
