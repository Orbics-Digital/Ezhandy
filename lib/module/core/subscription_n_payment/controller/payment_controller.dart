import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/data/payment_repository.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/provider_wallet_model.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/subscription_checkout_result.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/subscription_log_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  static PaymentController get i {
    if (!Get.isRegistered<PaymentController>()) {
      Get.put(PaymentController(), permanent: true);
    }
    return Get.find<PaymentController>();
  }

  final PaymentRepository _repository = PaymentRepository();

  final Rxn<ProviderWalletModel> providerWallet = Rxn<ProviderWalletModel>();
  final RxBool isProviderWalletLoading = false.obs;

  final Rxn<ProviderWalletModel> providerEarnings = Rxn<ProviderWalletModel>();
  final RxBool isProviderEarningsLoading = false.obs;

  final RxList<SubscriptionLogModel> subscriptionLogs = <SubscriptionLogModel>[].obs;
  final RxBool isSubscriptionLogsLoading = false.obs;

  final RxList<SubscriptionPlanModel> activePlans = <SubscriptionPlanModel>[].obs;
  final RxBool isActivePlansLoading = false.obs;
  final RxBool isCheckoutLoading = false.obs;
  final RxBool isVerifyCheckoutLoading = false.obs;

  List<ProviderPaymentLogModel> get paymentLogs =>
      providerWallet.value?.logs ?? [];

  List<ProviderPaymentLogModel> get earningLogs =>
      providerEarnings.value?.logs ?? [];

  List<SubscriptionLogModel> get currentSubscriptions =>
      subscriptionLogs.where((log) => !log.isExpired).toList();

  List<SubscriptionLogModel> get pastSubscriptions =>
      subscriptionLogs.where((log) => log.isExpired).toList();

  String get totalEarnedDisplay =>
      providerWallet.value?.displayTotalEarned ?? '\$0.00';

  String get earningsTotalDisplay =>
      providerEarnings.value?.displayTotalEarned ?? '\$0.00';

  Future<void> fetchProviderWallet() async {
    if (isProviderWalletLoading.value) return;

    isProviderWalletLoading.value = true;
    try {
      providerWallet.value = await _repository.getProviderWallet();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isProviderWalletLoading.value = false;
    }
  }

  Future<void> refreshProviderWallet() async {
    try {
      providerWallet.value = await _repository.getProviderWallet();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<void> fetchProviderEarnings() async {
    if (isProviderEarningsLoading.value) return;

    isProviderEarningsLoading.value = true;
    try {
      providerEarnings.value = await _repository.getProviderEarnings();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isProviderEarningsLoading.value = false;
    }
  }

  Future<void> refreshProviderEarnings() async {
    try {
      providerEarnings.value = await _repository.getProviderEarnings();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<void> fetchSubscriptionLogs() async {
    if (isSubscriptionLogsLoading.value) return;

    isSubscriptionLogsLoading.value = true;
    try {
      subscriptionLogs.assignAll(await _repository.getSubscriptionLogs());
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isSubscriptionLogsLoading.value = false;
    }
  }

  Future<void> refreshSubscriptionLogs() async {
    try {
      subscriptionLogs.assignAll(await _repository.getSubscriptionLogs());
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<void> fetchActiveSubscriptionPlans() async {
    if (isActivePlansLoading.value) return;

    isActivePlansLoading.value = true;
    try {
      activePlans.assignAll(await _repository.getActiveSubscriptionPlans());
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isActivePlansLoading.value = false;
    }
  }

  Future<void> refreshActiveSubscriptionPlans() async {
    try {
      activePlans.assignAll(await _repository.getActiveSubscriptionPlans());
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<SubscriptionCheckoutResult?> createSubscriptionCheckout(
    SubscriptionPlanModel plan,
  ) async {
    if (isCheckoutLoading.value) return null;
    if (plan.id == null) {
      AppDialogs.showToast(message: 'Invalid subscription plan.');
      return null;
    }

    isCheckoutLoading.value = true;
    try {
      return await _repository.createSubscriptionCheckout(plan: plan);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return null;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return null;
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  Future<bool> verifySubscriptionCheckout(String sessionId) async {
    final normalizedSessionId = sessionId.trim();
    if (normalizedSessionId.isEmpty) {
      AppDialogs.showToast(message: 'Missing checkout session.');
      return false;
    }
    if (isVerifyCheckoutLoading.value) return false;

    isVerifyCheckoutLoading.value = true;
    try {
      await _repository.verifySubscriptionCheckout(
        sessionId: normalizedSessionId,
      );
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isVerifyCheckoutLoading.value = false;
    }
  }
}
