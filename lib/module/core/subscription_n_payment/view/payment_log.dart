import 'package:ezhandy_user/module/core/subscription_n_payment/controller/payment_controller.dart';
import 'package:ezhandy_user/module/core/subscription_n_payment/model/provider_wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/row/two_text_row.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class PaymentLog extends StatefulWidget {
  PaymentLog({super.key});

  @override
  _PaymentLogState createState() => _PaymentLogState();
}

class _PaymentLogState extends State<PaymentLog> {
  final PaymentController _controller = PaymentController.i;

  @override
  void initState() {
    super.initState();
    _controller.fetchProviderWallet();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.paymentLog,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Column(
          children: [
            Obx(
              () => CustomContainer(
                bgColor: AppColors.orange,
                borderColor: AppColors.transparent,
                radius: 5.r,
                child: CustomText(
                  text:
                      '${AppStrings.totalEarnings} ${_controller.totalEarnedDisplay}',
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontSize: 16.sp,
                ),
              ),
            ),
            10.verticalSpace,
            Expanded(
              child: Obx(() {
                final logs = _controller.paymentLogs;
                final isLoading = _controller.isProviderWalletLoading.value;

                if (isLoading && logs.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.orange),
                  );
                }

                if (logs.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: _controller.refreshProviderWallet,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120.h),
                        const EmptyMessage(
                          message: AppStrings.noResultsFound,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.orange,
                  onRefresh: _controller.refreshProviderWallet,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: logs.length,
                    padding: EdgeInsets.only(bottom: AppPadding.padding18),
                    itemBuilder: (BuildContext ctxt, int index) {
                      return paymentLogCardWidget(logs[index]);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return 10.verticalSpace;
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentLogCardWidget(ProviderPaymentLogModel log) {
    return CustomContainer(
      child: Column(
        children: [
          10.verticalSpace,
          TwoTextRow(
            firstText: '${AppStrings.bookingId}:',
            secondText: log.displayBookingId,
          ),
          TwoTextRow(
            firstText: '${AppStrings.customerName}:',
            secondText: log.displayCustomerName,
          ),
          TwoTextRow(
            firstText: '${AppStrings.customerEmail}:',
            secondText: log.displayCustomerEmail,
          ),
          TwoTextRow(
            firstText: '${AppStrings.paymentDate}:',
            secondText: log.displayPaymentDate,
          ),
          TwoTextRow(
            firstText: '${AppStrings.grossAmount}:',
            secondText: log.displayGrossAmount,
          ),
          TwoTextRow(
            firstText: '${AppStrings.commission}:',
            secondText: log.displayCommission,
          ),
          TwoTextRow(
            firstText: '${AppStrings.paymentAmount}:',
            secondText: log.displayPaymentAmount,
          ),
          10.verticalSpace,
        ],
      ),
    );
  }
}
