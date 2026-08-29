import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_constants.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/products/model/marketplace_subscription_status.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/subscription_checkout_result.dart';

class MarketplaceSubscriptionRepository {
  MarketplaceSubscriptionRepository({ApiClient? apiClient})
      : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Map<String, dynamic> get _cacheBust => {
        '_': DateTime.now().millisecondsSinceEpoch,
      };

  Future<MarketplaceSubscriptionStatus> getStatus() async {
    final response = await _client.dio.get(
      ApiEndpoints.marketplaceSubscriptionStatus,
      queryParameters: _cacheBust,
    );
    final data = ApiHelper.dataObject(response.data);
    return MarketplaceSubscriptionStatus.fromJson(data);
  }

  Future<List<MarketplaceSubscriptionPlan>> getPlans() async {
    final response = await _client.dio.get(
      ApiEndpoints.marketplaceSubscriptionPlans,
      queryParameters: _cacheBust,
    );
    final data = ApiHelper.dataList(response.data);
    return data.map(MarketplaceSubscriptionPlan.fromJson).toList();
  }

  Future<List<MarketplaceSubscriptionHistoryItem>> getHistory() async {
    final response = await _client.dio.get(
      ApiEndpoints.marketplaceSubscriptionHistory,
      queryParameters: _cacheBust,
    );
    final data = ApiHelper.dataList(response.data);
    return data.map(MarketplaceSubscriptionHistoryItem.fromJson).toList();
  }

  Future<SubscriptionCheckoutResult> createCheckout({
    required int planId,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.marketplaceSubscriptionCheckout,
      data: {
        'planId': planId,
        'successUrl': ApiConstants.marketplaceSubscriptionCheckoutSuccessUrl,
        'cancelUrl': ApiConstants.marketplaceSubscriptionCheckoutCancelUrl,
      },
    );

    final root = response.data;
    if (root is! Map) {
      throw const FormatException('Invalid checkout response');
    }

    final map = Map<String, dynamic>.from(root);
    if (!ApiHelper.isSuccessResponse(map)) {
      throw Exception(
        ApiHelper.responseMessage(map) ?? 'Unable to start checkout',
      );
    }

    final extracted = _extractCheckoutData(map);
    if (extracted == null) {
      throw const FormatException('Checkout response missing data');
    }

    final url = (extracted['url'] ?? extracted['checkoutUrl'])
        ?.toString()
        .trim();
    if (url == null || url.isEmpty) {
      throw const FormatException('Checkout response did not include a url');
    }

    final sessionId =
        (extracted['sessionId'] ?? extracted['id'])?.toString().trim();

    return SubscriptionCheckoutResult(
      url: url,
      sessionId: sessionId?.isEmpty == true ? null : sessionId,
    );
  }

  Future<void> verifyCheckout({required String sessionId}) async {
    final response = await _client.dio.post(
      ApiEndpoints.marketplaceSubscriptionVerifyCheckout,
      data: {'sessionId': sessionId},
    );

    if (response.data is! Map) return;

    final root = Map<String, dynamic>.from(response.data as Map);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(
        ApiHelper.responseMessage(root) ?? 'Failed to verify checkout',
      );
    }
  }

  Map<String, dynamic>? _extractCheckoutData(Map<String, dynamic> response) {
    final outer = response['data'];
    if (outer is! Map) return null;

    final inner = outer['data'];
    if (inner is Map) {
      return Map<String, dynamic>.from(inner);
    }
    return Map<String, dynamic>.from(outer);
  }

  String errorMessage(Object error) {
    if (error is DioException) return ApiHelper.errorMessage(error);
    return error.toString();
  }
}
