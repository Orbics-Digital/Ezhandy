import 'package:ezhandy_user/module/core/chat/controller/chat_controller.dart';
import 'package:ezhandy_user/module/core/chat/model/my_chat_model.dart';
import 'package:ezhandy_user/module/core/chat/routing_arguments/chat_routing_arguments.dart';
import 'package:ezhandy_user/module/core/main_menu/main_menu_provider.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/profile_widget/user_image_widget.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/notification/notification_badge_icon.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatController _controller = ChatController.i;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.fetchMyChats();
    _searchController.addListener(() {
      _controller.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          10.verticalSpace,
          appbarWidget(),
          20.verticalSpace,
          searchTextField(),
          10.verticalSpace,
          CustomButton(
            text: "Pro Chats",
            color: AppColors.black,
            onclick: () {
              AppNavigation.navigateTo(context, AppRoutes.proChatScreenRoute);
            },
          ),
          Expanded(
            child: Obx(() {
              final chats = _controller.filteredMyChats;
              final isLoading = _controller.isMyChatsLoading.value;

              if (isLoading && _controller.myChats.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.orange,
                  ),
                );
              }

              if (chats.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.orange,
                  onRefresh: _controller.refreshMyChats,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 120.h),
                      EmptyMessage(
                        message: _controller.searchQuery.value.trim().isEmpty
                            ? AppStrings.noChatsFound
                            : AppStrings.noResultsFound,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.orange,
                onRefresh: _controller.refreshMyChats,
                child: ListView.separated(
                  padding: EdgeInsets.only(
                    top: AppPadding.padding20,
                    bottom: AppPadding.padding25,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return singleWidget(
                      chat: chat,
                      ontap: () {
                        AppNavigation.navigateTo(
                          context,
                          AppRoutes.chatScreenRoute,
                          arguments: ChatRoutingArgument(isBooking: true),
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
          ),
        ],
      ),
    );
  }

  Widget searchTextField() {
    return CustomTextField(
      label: false,
      prefxicon: AssetPath.searchIcon,
      hint: AppStrings.searchAnything,
      controller: _searchController,
      inputFormatters: [LengthLimitingTextInputFormatter(35)],
    );
  }

  Row appbarWidget() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            globalkey.currentState!.openDrawer();
          },
          child: Image.asset(
            AssetPath.menuIcon,
            alignment: Alignment.centerLeft,
            scale: 4.sp,
            color: AppColors.black,
          ),
        ),
        10.horizontalSpace,
        CustomText(
          text: AppStrings.messages,
          fontWeight: FontWeight.w500,
          fontSize: 20.sp,
        ),
        const Spacer(),
        const NotificationBadgeIcon(),
      ],
    );
  }

  Widget singleWidget({
    required MyChatModel chat,
    required VoidCallback ontap,
  }) {
    final profileImage = chat.otherUser?.profileImage?.trim();
    final lastMessage = chat.displayLastMessage;

    return CustomContainer(
      onTap: ontap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserImageWidget(
            image: profileImage != null && profileImage.isNotEmpty
                ? profileImage
                : null,
          ),
          5.horizontalSpace,
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: chat.otherUser?.displayName ?? '-',
                  color: AppColors.orange,
                  fontWeight: FontWeight.w500,
                ),
                5.verticalSpace,
                CustomText(
                  text: lastMessage.isNotEmpty ? lastMessage : '-',
                  maxLines: 1,
                  fontSize: 12.sp,
                ),
              ],
            ),
          ),
          const Spacer(),
          CustomText(
            text: chat.displayTime,
            color: AppColors.greyLight,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
