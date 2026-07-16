import 'package:ezhandy_user/module/core/subscription_n_payment/controller/payment_controller.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/subscription_log_model.dart';
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
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/row/two_text_row.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class SubscriptionLog extends StatefulWidget {
  SubscriptionLog({super.key});

  @override
  _SubscriptionLogState createState() => _SubscriptionLogState();
}

class _SubscriptionLogState extends State<SubscriptionLog> {
  final PaymentController _controller = PaymentController.i;

  @override
  void initState() {
    super.initState();
    _controller.fetchSubscriptionLogs();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.subscriptionLog,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Obx(() {
          final isLoading = _controller.isSubscriptionLogsLoading.value;
          final currentSubscriptions = _controller.currentSubscriptions;
          final pastSubscriptions = _controller.pastSubscriptions;

          if (isLoading && _controller.subscriptionLogs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            );
          }

          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: _controller.refreshSubscriptionLogs,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: AppStrings.currentSubscription,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  10.verticalSpace,
                  if (currentSubscriptions.isEmpty)
                    CustomContainer(
                      child: const EmptyMessage(
                        message: AppStrings.noResultsFound,
                      ),
                    )
                  else
                    ...currentSubscriptions.map(
                      (subscription) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _subscriptionCard(
                          subscription: subscription,
                          showCancelButton: true,
                        ),
                      ),
                    ),
                  20.verticalSpace,
                  CustomText(
                    text: AppStrings.pastSubscription,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  10.verticalSpace,
                  if (pastSubscriptions.isEmpty)
                    CustomContainer(
                      child: const EmptyMessage(
                        message: AppStrings.noResultsFound,
                      ),
                    )
                  else
                    CustomContainer(
                      isPadding: false,
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: pastSubscriptions.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (BuildContext context, int index) {
                          return _pastSubscriptionWidget(
                            pastSubscriptions[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            color: AppColors.blueDark,
                          );
                        },
                      ),
                    ),
                  25.verticalSpace,
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _subscriptionCard({
    required SubscriptionLogModel subscription,
    required bool showCancelButton,
  }) {
    return CustomContainer(
      child: Column(
        children: [
          _subscriptionDetails(subscription),
          if (showCancelButton) ...[
            10.verticalSpace,
            cancelBtnWidget(context),
          ],
        ],
      ),
    );
  }

  Widget _pastSubscriptionWidget(SubscriptionLogModel subscription) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      child: _subscriptionDetails(subscription),
    );
  }

  Widget _subscriptionDetails(SubscriptionLogModel subscription) {
    return Column(
      children: [
        10.verticalSpace,
        TwoTextRow(
          firstText: '${AppStrings.subscribedOn}:',
          secondText: subscription.displaySubscribedOn,
        ),
        10.verticalSpace,
        TwoTextRow(
          firstText: '${AppStrings.expiresOn}:',
          secondText: subscription.displayExpiresOn,
        ),
        10.verticalSpace,
        TwoTextRow(
          firstText: '${AppStrings.amountPaid}:',
          secondText: subscription.displayAmountPaid,
        ),
        10.verticalSpace,
        TwoTextRow(
          firstText: '${AppStrings.duration}:',
          secondText: subscription.displayDuration,
        ),
        10.verticalSpace,
      ],
    );
  }

  Widget cancelBtnWidget(BuildContext context) {
    return CustomButton(
      onclick: () {
        AppDialogs.showSuccessDialog(
          context,
          description: AppStrings.cancelSubscriptionText,
          title: AppStrings.cancelSubscription,
          image: AssetPath.alertIcon,
          isDoneShow: false,
          btnTxt1: AppStrings.no,
          onTap1: () {
            AppNavigation.navigatorPop(context);
          },
          btnTxt2: AppStrings.yes,
          onTap2: () {
            AppNavigation.navigatorPopUntil(
              context,
              AppRoutes.mainMenuScreenRoute,
            );
          },
        );
      },
      text: AppStrings.cancelSubscription,
    );
  }
}
