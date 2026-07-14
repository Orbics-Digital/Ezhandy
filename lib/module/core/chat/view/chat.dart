import 'dart:io';

import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/core/chat/controller/chat_controller.dart';
import 'package:ezhandy_user/module/core/chat/model/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/widgets/Container/bubble_chat_container.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';

class ChatScreen extends StatefulWidget {
  final bool isBooking;
  final String? chatId;
  final String? otherUserName;

  ChatScreen({
    this.isBooking = false,
    this.chatId,
    this.otherUserName,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ChatController _controller = ChatController.i;
  final List<ChatModel> _localMessages = [];

  bool get _hasChatId {
    final id = widget.chatId?.trim();
    return id != null && id.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    if (_hasChatId) {
      _controller.clearChatHistory();
      _controller.fetchChatHistory(widget.chatId!.trim());
    }
  }

  String? get _currentUserId => AuthController.i.user.value?.sub?.trim();

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () => Get.back(),
      title: widget.otherUserName?.trim().isNotEmpty == true
          ? widget.otherUserName!.trim()
          : AppStrings.dummyName,
      child: Column(
        children: [
          Expanded(
            child: _hasChatId ? _buildHistoryList() : _buildLocalMessagesList(),
          ),
          CustomContainer(
            borderColor: AppColors.transparent,
            radius: 0,
            bgColor: AppColors.orange,
            child: Padding(
              padding: Platform.isAndroid
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(bottom: AppPadding.padding25),
              child: Row(
                children: [
                  GestureDetector(
                    child: Image.asset(
                      AssetPath.emojiIcon,
                      width: 27.w,
                      height: 27.h,
                    ),
                  ),
                  10.horizontalSpace,
                  Expanded(child: _messageTextField()),
                  10.horizontalSpace,
                  GestureDetector(
                    child: Image.asset(
                      AssetPath.cameraIcon,
                      width: 30.w,
                      height: 30.h,
                    ),
                  ),
                  10.horizontalSpace,
                  GestureDetector(
                    child: Image.asset(
                      AssetPath.mikeIcon,
                      width: 27.w,
                      height: 27.h,
                    ),
                  ),
                  10.horizontalSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Obx(() {
      final isLoading = _controller.isChatHistoryLoading.value;
      final messages = _controller.chatHistory;

      if (isLoading && messages.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        );
      }

      if (messages.isEmpty) {
        return const EmptyMessage(message: AppStrings.noChatsFound);
      }

      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final current = messages[index];
          final prev = index > 0 ? messages[index - 1] : null;
          final currentTime = current.createdAt;
          final showDateDivider = currentTime != null &&
              (prev == null ||
                  prev.createdAt == null ||
                  !_isSameDate(currentTime, prev.createdAt!));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateDivider) _buildDateDivider(currentTime),
              ChatBubble(
                name: current.senderDisplayName,
                text: current.displayContent.isNotEmpty
                    ? current.displayContent
                    : '-',
                isSender: !current.isSentBy(_currentUserId),
                profileImage: current.sender?.profileImage,
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => 20.verticalSpace,
      );
    });
  }

  Widget _buildLocalMessagesList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.padding12),
      itemCount: _localMessages.length,
      itemBuilder: (context, index) {
        final current = _localMessages[index];
        final prev = index > 0 ? _localMessages[index - 1] : null;
        final showDateDivider =
            prev == null || !_isSameDate(current.time, prev.time);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateDivider) _buildDateDivider(current.time),
            ChatBubble(
              name: AppStrings.dummyName,
              text: current.text,
              isSender: !current.isSender,
              profileImage: AuthController.i.user.value?.profileImage,
            ),
          ],
        );
      },
      separatorBuilder: (context, index) => 20.verticalSpace,
    );
  }

  Widget _messageTextField() {
    return CustomTextField(
      borderRadius: 5.r,
      borderColor: AppColors.white,
      fillColor: AppColors.transparent,
      hint: AppStrings.message,
      fontColor: AppColors.white,
      hintColor: AppColors.white,
      divider: false,
      label: false,
      sufixImage: Image.asset(AssetPath.sendIcon, width: 30.w, height: 30.h),
      onclickSufix: () {
        if (messageController.text.trim().isEmpty) return;

        setState(() {
          _localMessages.add(
            ChatModel(
              text: messageController.text,
              isSender: true,
              time: DateTime.now().toUtc(),
            ),
          );
          messageController.clear();
        });
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(Constants.descriptionMaxLength),
      ],
      controller: messageController,
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.grey)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              _formatDate(date.toLocal()),
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        ],
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_monthName(date.month)}, ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }
}
