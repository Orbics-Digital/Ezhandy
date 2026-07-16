import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/booking/model/booking_detail_model.dart';
import 'package:ezhandy_user/module/core/booking/model/provider_booking_model.dart';

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
}
