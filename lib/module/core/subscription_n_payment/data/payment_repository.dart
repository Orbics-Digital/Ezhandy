import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_constants.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/provider_wallet_model.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/subscription_checkout_result.dart';
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

  Future<ProviderWalletModel> getProviderEarnings() async {
    final response = await _client.dio.get(ApiEndpoints.providerEarnings);
    final data = ApiHelper.dataObject(response.data);
    return ProviderWalletModel.fromJson(data);
  }

  Future<List<SubscriptionLogModel>> getSubscriptionLogs() async {
    final response = await _client.dio.get(ApiEndpoints.paymentLogs);
    final data = ApiHelper.dataList(response.data);
    return data.map(SubscriptionLogModel.fromJson).toList();
  }

  Future<List<SubscriptionPlanModel>> getActiveSubscriptionPlans() async {
    final response =
        await _client.dio.get(ApiEndpoints.activeSubscriptionPlans);
    final data = ApiHelper.dataList(response.data);
    return data.map(SubscriptionPlanModel.fromJson).toList();
  }

  Future<SubscriptionCheckoutResult> createSubscriptionCheckout({
    required SubscriptionPlanModel plan,
  }) async {
    final packageType = plan.packageType?.trim() ?? '';
    final response = await _client.dio.post(
      ApiEndpoints.createSubscriptionCheckout,
      data: {
        'amount': plan.amountInCents,
        'cancelUrl': '${ApiConstants.webBaseUrl}/subscription-plans',
        'currency': 'usd',
        'packageType': packageType,
        'planDescription': packageType,
        'planId': plan.id,
        'planTitle': plan.displayTitle,
        'successUrl':
            '${ApiConstants.webBaseUrl}/subscription-success?session_id={CHECKOUT_SESSION_ID}',
      },
    );

    final data = ApiHelper.dataObject(response.data);
    return SubscriptionCheckoutResult.fromJson(data);
  }

  Future<void> verifySubscriptionCheckout({
    required String sessionId,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.verifySubscriptionCheckout,
      data: {
        'sessionId': sessionId,
      },
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(
        ApiHelper.responseMessage(root) ?? 'Failed to verify subscription',
      );
    }
  }
}
