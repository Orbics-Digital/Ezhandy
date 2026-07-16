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
                ontap1: () => _onAcceptTap(request),
                ontap2: () => _onRejectTap(request),
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

  void _onAcceptTap(AskProRequestModel request) {
    AppDialogs.showSuccessDialog(
      context,
      description: 'Are you sure you want to accept this request?',
      image: AssetPath.tumbIcon,
      isDoneShow: false,
      btnTxt1: AppStrings.yes,
      btnTxt2: AppStrings.no,
      onTap1: () async {
        AppNavigation.navigateCloseDialog(context);

        final requestId = request.id?.trim();
        if (requestId == null || requestId.isEmpty) return;

        final otherUserName = request.user?.displayName;
        final result = await _controller.acceptRequest(requestId);
        if (!mounted || result == null) return;

        final chatId = result.chatId?.trim();
        if (chatId == null || chatId.isEmpty) {
          AppDialogs.showToast(message: 'Unable to open chat.');
          return;
        }

        AppNavigation.navigateTo(
          context,
          AppRoutes.chatScreenRoute,
          arguments: ChatRoutingArgument(
            isBooking: false,
            chatId: chatId,
            chatType: 'ask_pro',
            otherUserName: otherUserName,
            otherUserId: request.user?.id ?? request.userId,
            otherUserImage: request.user?.profileImage,
          ),
        );
      },
      onTap2: () {
        AppNavigation.navigateCloseDialog(context);
      },
    );
  }

  void _onRejectTap(AskProRequestModel request) {
    AppDialogs.showSuccessDialog(
      context,
      description: 'Are you sure you want to reject this request?',
      image: AssetPath.tumbIcon,
      isDoneShow: false,
      btnTxt1: AppStrings.yes,
      btnTxt2: AppStrings.no,
      onTap1: () async {
        AppNavigation.navigateCloseDialog(context);

        final requestId = request.id?.trim();
        if (requestId == null || requestId.isEmpty) return;

        final success = await _controller.rejectRequest(requestId);
        if (!mounted || !success) return;

        AppDialogs.showSuccessDialog(
          context,
          description: AppStrings.requestHasBeenRejectedSuccessfully,
          title: AppStrings.congratulation,
          btnTxt1: AppStrings.ok,
          onTap1: () {
            if (!mounted) return;
            AppNavigation.navigateCloseDialog(context);
          },
        );
      },
      onTap2: () {
        AppNavigation.navigateCloseDialog(context);
      },
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
