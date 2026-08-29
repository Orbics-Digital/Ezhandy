import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_constants.dart';
import 'package:ezhandy_user/module/core/products/data/marketplace_subscription_repository.dart';
import 'package:ezhandy_user/module/core/products/model/marketplace_subscription_status.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/routing_arguments/checkout_webview_routing_arguments.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_loader.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketplaceSubscriptionController extends GetxController {
  MarketplaceSubscriptionController({
    MarketplaceSubscriptionRepository? repository,
  }) : _repository = repository ?? MarketplaceSubscriptionRepository();

  final MarketplaceSubscriptionRepository _repository;

  final RxBool isCheckingStatus = false.obs;
  final RxBool isLoadingStatus = false.obs;
  final RxBool isLoadingPlans = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isCheckoutLoading = false.obs;
  final Rxn<MarketplaceSubscriptionStatus> status =
      Rxn<MarketplaceSubscriptionStatus>();
  final RxList<MarketplaceSubscriptionPlan> plans =
      <MarketplaceSubscriptionPlan>[].obs;
  final RxList<MarketplaceSubscriptionHistoryItem> history =
      <MarketplaceSubscriptionHistoryItem>[].obs;
  final RxnInt selectedPlanId = RxnInt();

  bool get hasActiveSubscription =>
      status.value?.hasActiveSubscription == true;

  MarketplaceSubscriptionPlan? get selectedPlan {
    final id = selectedPlanId.value;
    if (id == null) return null;
    for (final plan in plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  void selectPlan(int planId) {
    selectedPlanId.value = planId;
  }

  int? get activePlanId => status.value?.activePlanId;

  bool isCurrentActivePlan(int planId) {
    final activeId = activePlanId;
    return activeId != null && activeId == planId;
  }

  bool get isSelectedPlanAlreadyActive {
    final selected = selectedPlanId.value;
    if (selected == null) return false;
    return isCurrentActivePlan(selected);
  }

  Future<void> loadPlans() async {
    isLoadingPlans.value = true;
    try {
      await fetchStatus(showLoader: false);
      final result = await fetchPlans(showLoader: false);
      plans.assignAll(result);
      if (selectedPlanId.value == null && result.isNotEmpty) {
        final popular = result.where((p) => p.popular).toList();
        selectedPlanId.value =
            popular.isNotEmpty ? popular.first.id : result.first.id;
      }
    } finally {
      isLoadingPlans.value = false;
    }
  }

  Future<bool> ensureCanAddProduct(BuildContext context) async {
    if (isCheckingStatus.value) return false;

    isCheckingStatus.value = true;
    try {
      final result = await fetchStatus(showLoader: true);

      if (!context.mounted) return false;

      if (result == null) {
        AppDialogs.showToast(
          message: AppStrings.unableToCheckMarketplaceSubscription,
        );
        return false;
      }

      status.value = result;

      if (!result.hasActiveSubscription) {
        await AppDialogs.showSuccessDialog(
          context,
          title: AppStrings.subscription,
          description: AppStrings.marketplaceSubscriptionRequiredMessage,
          isDoneShow: false,
          btnTxt1: AppStrings.viewSubscriptions,
          btnTxt2: AppStrings.cancel,
          onTap1: () {
            AppNavigation.navigatorPop(context);
            AppNavigation.navigateTo(
              context,
              AppRoutes.marketplaceSubscriptionPlansScreenRoute,
            );
          },
          onTap2: () => AppNavigation.navigatorPop(context),
        );
        return false;
      }

      if (result.isProductLimitReached) {
        await AppDialogs.showSuccessDialog(
          context,
          title: AppStrings.subscription,
          description: AppStrings.productLimitReachedMessage,
          isDoneShow: false,
          btnTxt1: AppStrings.viewSubscriptions,
          btnTxt2: AppStrings.cancel,
          onTap1: () {
            AppNavigation.navigatorPop(context);
            AppNavigation.navigateTo(
              context,
              AppRoutes.marketplaceSubscriptionPlansScreenRoute,
            );
          },
          onTap2: () => AppNavigation.navigatorPop(context),
        );
        return false;
      }

      return true;
    } finally {
      isCheckingStatus.value = false;
    }
  }

  Future<MarketplaceSubscriptionStatus?> fetchStatus({
    bool showLoader = false,
  }) async {
    isLoadingStatus.value = true;
    if (showLoader) AppLoader.show();

    try {
      final parsed = await _repository.getStatus();
      status.value = parsed;
      return parsed;
    } on DioException catch (e) {
      AppDialogs.showToast(message: _repository.errorMessage(e));
      return null;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return null;
    } finally {
      if (showLoader) AppLoader.hide();
      isLoadingStatus.value = false;
    }
  }

  Future<List<MarketplaceSubscriptionPlan>> fetchPlans({
    bool showLoader = true,
  }) async {
    if (showLoader) AppLoader.show();
    try {
      return await _repository.getPlans();
    } on DioException catch (e) {
      AppDialogs.showToast(message: _repository.errorMessage(e));
      return const [];
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return const [];
    } finally {
      if (showLoader) AppLoader.hide();
    }
  }

  Future<void> loadHistory() async {
    isLoadingHistory.value = true;
    try {
      final result = await fetchHistory(showLoader: false);
      history.assignAll(result);
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<List<MarketplaceSubscriptionHistoryItem>> fetchHistory({
    bool showLoader = true,
  }) async {
    if (showLoader) AppLoader.show();
    try {
      return await _repository.getHistory();
    } on DioException catch (e) {
      AppDialogs.showToast(message: _repository.errorMessage(e));
      return const [];
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return const [];
    } finally {
      if (showLoader) AppLoader.hide();
    }
  }

  Future<void> startCheckout(BuildContext context, {required int planId}) async {
    if (isCheckoutLoading.value) return;

    isCheckoutLoading.value = true;
    AppLoader.show();
    try {
      final checkout = await _repository.createCheckout(planId: planId);
      AppLoader.hide();
      isCheckoutLoading.value = false;

      if (!context.mounted) return;

      final paid = await Navigator.pushNamed(
        context,
        AppRoutes.checkoutWebViewScreenRoute,
        arguments: CheckoutWebViewRoutingArgument(
          url: checkout.url,
          sessionId: checkout.sessionId,
          successPath:
              ApiConstants.marketplaceSubscriptionCheckoutSuccessPath,
          cancelPath: ApiConstants.marketplaceSubscriptionCheckoutCancelPath,
        ),
      );

      if (paid != true || !context.mounted) return;

      final sessionId = checkout.sessionId?.trim() ?? '';
      if (sessionId.isEmpty) {
        AppDialogs.showToast(message: 'Missing checkout session.');
        return;
      }

      AppLoader.show();
      await _repository.verifyCheckout(sessionId: sessionId);
      await fetchStatus(showLoader: false);
      AppLoader.hide();

      if (!context.mounted) return;
      AppDialogs.showToast(message: AppStrings.subscribedSuccessful);
      Get.back();
    } on DioException catch (e) {
      AppLoader.hide();
      isCheckoutLoading.value = false;
      AppDialogs.showToast(message: _repository.errorMessage(e));
    } catch (e) {
      AppLoader.hide();
      isCheckoutLoading.value = false;
      AppDialogs.showToast(message: e.toString());
    }
  }
}
