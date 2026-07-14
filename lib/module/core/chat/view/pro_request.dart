import 'package:ezhandy_user/module/core/chat/controller/ask_pro_controller.dart';
import 'package:ezhandy_user/module/core/chat/model/ask_pro_request_model.dart';
import 'package:ezhandy_user/module/core/chat/routing_arguments/chat_routing_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class ProRequest extends StatefulWidget {
  ProRequest({super.key});

  @override
  State<ProRequest> createState() => _ProRequestState();
}

class _ProRequestState extends State<ProRequest> {
  final AskProController _controller = AskProController.i;

  @override
  void initState() {
    super.initState();
    _controller.fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () {
        Get.back();
      },
      title: AppStrings.proRequest,
      child: Obx(() {
        final requests = _controller.requests;
        final isLoading = _controller.isRequestsLoading.value;

        if (isLoading && requests.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.orange),
          );
        }

        if (requests.isEmpty) {
          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: _controller.refreshRequests,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 120.h),
                const EmptyMessage(message: AppStrings.noResultsFound),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.orange,
          onRefresh: _controller.refreshRequests,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.padding14,
              vertical: AppPadding.padding20,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return singleWidget(
                request: request,
                ontap1: () {
                  AppDialogs.showSuccessDialog(
                    context,
                    description:
                        AppStrings.requestHasBeenAcceptedSuccessfully,
                    title: AppStrings.congratulation,
                    btnTxt1: AppStrings.ok,
                    onTap1: () {
                      AppNavigation.navigatorPop(context);
                      AppNavigation.navigateTo(
                        context,
                        AppRoutes.chatScreenRoute,
                        arguments: ChatRoutingArgument(isBooking: false),
                      );
                    },
                  );
                },
                ontap2: () {
                  AppDialogs.showSuccessDialog(
                    context,
                    description:
                        AppStrings.requestHasBeenRejectedSuccessfully,
                    title: AppStrings.congratulation,
                    btnTxt1: AppStrings.ok,
                    onTap1: () {
                      AppNavigation.navigatorPop(context);
                      AppNavigation.navigatorPopUntil(
                        context,
                        AppRoutes.proRequestScreenRoute,
                      );
                    },
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return 10.verticalSpace;
            },
          ),
        );
      }),
    );
  }

  Widget singleWidget({
    required AskProRequestModel request,
    required VoidCallback ontap1,
    required VoidCallback ontap2,
  }) {
    return CustomContainer(
      child: Column(
        children: [
          CustomText(
            text: request.displayTitle,
            fontWeight: FontWeight.bold,
          ),
          5.verticalSpace,
          CustomText(text: request.displayQuestion),
          10.verticalSpace,
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: AppStrings.accept,
                  height: 40.h,
                  onclick: ontap1,
                ),
              ),
              10.horizontalSpace,
              Expanded(
                child: CustomButton(
                  text: AppStrings.reject,
                  height: 40.h,
                  color: AppColors.black,
                  onclick: ontap2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
