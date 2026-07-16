import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/data/payment_repository.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/provider_wallet_model.dart';
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

  List<ProviderPaymentLogModel> get paymentLogs =>
      providerWallet.value?.logs ?? [];

  String get totalEarnedDisplay =>
      providerWallet.value?.displayTotalEarned ?? '\$0.00';

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
}
