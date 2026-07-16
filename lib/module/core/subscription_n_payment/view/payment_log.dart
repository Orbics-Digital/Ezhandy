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
        child: Obx(() {
          final logs = _controller.paymentLogs;
          final isLoading = _controller.isProviderWalletLoading.value;
          final wallet = _controller.providerWallet.value;

          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: _controller.refreshProviderWallet,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _walletOverviewSection(wallet),
                ),
                SliverToBoxAdapter(child: 10.verticalSpace),
                if (isLoading && logs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orange,
                      ),
                    ),
                  )
                else if (logs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyMessage(
                        message: AppStrings.noResultsFound,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: AppPadding.padding18),
                    sliver: SliverList.separated(
                      itemCount: logs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return paymentLogCardWidget(logs[index]);
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return 10.verticalSpace;
                      },
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _walletOverviewSection(ProviderWalletModel? wallet) {
    final data = wallet ?? const ProviderWalletModel();

    return Column(
      children: [
        CustomContainer(
          bgColor: AppColors.orange,
          borderColor: AppColors.transparent,
          radius: 12.r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: AppStrings.availableBalance,
                color: AppColors.white.withValues(alpha: 0.9),
                fontSize: 12.sp,
              ),
              6.verticalSpace,
              CustomText(
                text: data.displayAvailableBalance,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28.sp,
              ),
              18.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: _walletMetric(
                      label: AppStrings.totalEarned,
                      value: data.displayWalletTotalEarned,
                    ),
                  ),
                  Expanded(
                    child: _walletMetric(
                      label: AppStrings.withdrawn,
                      value: data.displayWalletTotalWithdrawn,
                    ),
                  ),
                  Expanded(
                    child: _walletMetric(
                      label: AppStrings.currency,
                      value: data.displayCurrency,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        10.verticalSpace,
        _summaryCard(
          iconPath: AssetPath.earningIcon,
          iconBackground: const Color(0xFFF8E8D6),
          label: AppStrings.grossEarnings,
          value: data.displayGrossTotal,
          valueColor: AppColors.black,
        ),
        8.verticalSpace,
        _summaryCard(
          icon: Icons.percent,
          iconBackground: const Color(0xFFF8E8D6),
          label: AppStrings.commissionDeducted,
          value: data.displayCommissionDeducted,
          valueColor: AppColors.red,
        ),
        8.verticalSpace,
        _summaryCard(
          iconPath: AssetPath.bankIcon,
          iconBackground: const Color(0xFFE8E4F3),
          label: AppStrings.netPayout,
          value: data.displayNetTotal,
          valueColor: AppColors.green,
        ),
      ],
    );
  }

  Widget _walletMetric({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: AppColors.white.withValues(alpha: 0.85),
          fontSize: 11.sp,
        ),
        4.verticalSpace,
        CustomText(
          text: value,
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
      ],
    );
  }

  Widget _summaryCard({
    String? iconPath,
    IconData? icon,
    required Color iconBackground,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return CustomContainer(
      radius: 10.r,
      child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: iconPath != null
                  ? Image.asset(iconPath, width: 18.w, height: 18.h)
                  : Icon(icon, size: 18.sp, color: AppColors.orange),
            ),
            8.horizontalSpace,
            CustomText(
              text: label,
              color: AppColors.grey,
              fontSize: 12.sp,
              maxLines: 2,
            ),
            Expanded(
              child: CustomText(
                text: value,
                align: Alignment.centerRight,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                color: valueColor,
                maxLines: 1,
              ),
            ),
          ],
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
