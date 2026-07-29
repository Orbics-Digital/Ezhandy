import 'package:carousel_slider/carousel_slider.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/controller/payment_controller.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/subscription_log_model.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/routing_arguments/checkout_webview_routing_arguments.dart';
import 'package:ezhandy_user/utils/app_loader.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class SubscriptionScreen extends StatefulWidget {
  SubscriptionScreen({
    super.key,
  });

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PaymentController _controller = PaymentController.i;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.fetchActiveSubscriptionPlans().then((_) {
      if (!mounted) return;
      final plans = _controller.activePlans;
      if (plans.isEmpty) return;
      final popularIndex = plans.indexWhere((plan) => plan.popular);
      setState(() {
        _selectedIndex = popularIndex >= 0 ? popularIndex : 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.subscriptionPlan,
      child: Obx(() {
        final isLoading = _controller.isActivePlansLoading.value;
        final plans = _controller.activePlans;

        if (isLoading && plans.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.orange),
          );
        }

        if (plans.isEmpty) {
          return const Center(
            child: EmptyMessage(message: AppStrings.noResultsFound),
          );
        }

        return Column(
          children: [
            30.verticalSpace,
            subscriptionSlider(plans),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.padding12),
              child: btn_widget(context),
            ),
            25.verticalSpace,
          ],
        );
      }),
    );
  }

  Widget btn_widget(BuildContext context) {
    return Obx(() {
      return CustomButton(
        isLoading: _controller.isCheckoutLoading.value,
        onclick: () => _onBuyNow(context),
        text: AppStrings.buyNow,
      );
    });
  }

  Future<void> _onBuyNow(BuildContext context) async {
    final plans = _controller.activePlans;
    if (plans.isEmpty) return;

    final safeIndex = _selectedIndex.clamp(0, plans.length - 1);
    final checkout =
        await _controller.createSubscriptionCheckout(plans[safeIndex]);
    if (checkout == null || !context.mounted) return;

    // Ensure Buy Now loader is cleared before opening checkout.
    _controller.isCheckoutLoading.value = false;
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;

    final paid = await Navigator.pushNamed(
      context,
      AppRoutes.checkoutWebViewScreenRoute,
      arguments: CheckoutWebViewRoutingArgument(
        url: checkout.url,
        sessionId: checkout.sessionId,
      ),
    );

    if (paid != true || !context.mounted) return;

    final sessionId = checkout.sessionId?.trim() ?? '';
    if (sessionId.isEmpty) {
      AppDialogs.showToast(message: 'Missing checkout session.');
      return;
    }

    AppLoader.show();
    final verified = await _controller.verifySubscriptionCheckout(sessionId);
    if (!verified) {
      AppLoader.hide();
      return;
    }

    final profileLoaded = await AuthController.i.fetchProfileDetails();
    if (!profileLoaded) {
      await AuthController.i.markSubscriptionActive();
    }
    AppLoader.hide();
    if (!context.mounted) return;

    AppDialogs.showSuccessDialog(
      context,
      description: AppStrings.paymentSuccessfullyMade,
      title: AppStrings.paymentDone,
      btnTxt1: AppStrings.done,
      onTap1: () {
        AppNavigation.navigateToRemovingAll(
          context,
          AppRoutes.mainMenuScreenRoute,
        );
      },
    );
  }

  Widget subscriptionSlider(List<SubscriptionPlanModel> plans) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: plans.length,
          options: CarouselOptions(
            height: 400.h,
            enlargeCenterPage: false,
            autoPlay: false,
            enableInfiniteScroll: plans.length > 1,
            viewportFraction: 0.85,
            initialPage: _selectedIndex.clamp(0, plans.length - 1),
            onPageChanged: (index, reason) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final plan = plans[index];
            final isSelected = _selectedIndex == index;
            return _planCard(plan: plan, isSelected: isSelected);
          },
        ),
        12.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: plans.asMap().entries.map((entry) {
            final isActive = _selectedIndex == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 8.h,
              width: isActive ? 24.w : 8.w,
              decoration: BoxDecoration(
                color: isActive ? AppColors.orange : AppColors.grey,
                borderRadius: BorderRadius.circular(20.r),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _planCard({
    required SubscriptionPlanModel plan,
    required bool isSelected,
  }) {
    final originalPrice = plan.displayOriginalPrice;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      width: 343.w,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.orange : AppColors.black,
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: plan.displayTitle,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              if (plan.popular)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: CustomText(
                    text: 'Popular',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
          6.verticalSpace,
          CustomText(
            text: plan.displayDuration,
            fontSize: 14.sp,
            color: AppColors.white,
          ),
          10.verticalSpace,
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: plan.features
                    .map(
                      (feature) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Icon(
                                Icons.check_circle,
                                size: 16.sp,
                                color: AppColors.white,
                              ),
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: CustomText(
                                text: feature,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          10.verticalSpace,
          if (originalPrice != null) ...[
            CustomText(
              text: originalPrice,
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 16.sp,
              textDecoration: TextDecoration.lineThrough,
            ),
            4.verticalSpace,
          ],
          CustomText(
            text: 'Price:  ${plan.displayPrice}',
            color: AppColors.white,
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
