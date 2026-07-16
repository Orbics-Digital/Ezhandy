import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/provider_wallet_model.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/subscription_log_model.dart';

class PaymentRepository {
  PaymentRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<ProviderWalletModel> getProviderWallet() async {
    final response = await _client.dio.get(ApiEndpoints.providerWallet);
    final data = ApiHelper.dataObject(response.data);
    return ProviderWalletModel.fromJson(data);
  }

  Future<List<SubscriptionLogModel>> getSubscriptionLogs() async {
    final response = await _client.dio.get(ApiEndpoints.paymentLogs);
    final data = ApiHelper.dataList(response.data);
    return data.map(SubscriptionLogModel.fromJson).toList();
  }
}
