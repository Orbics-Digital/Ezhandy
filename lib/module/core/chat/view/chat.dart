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
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/widgets/Container/bubble_chat_container.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class ChatScreen extends StatefulWidget {
  final bool isBooking;
  final String? chatId;
  final String? chatType;
  final String? otherUserName;
  final String? otherUserId;
  final String? otherUserImage;

  ChatScreen({
    this.isBooking = false,
    this.chatId,
    this.chatType,
    this.otherUserName,
    this.otherUserId,
    this.otherUserImage,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatController _controller = ChatController.i;
  final List<ChatModel> _localMessages = [];
  int _lastMessageCount = 0;

  bool get _hasChatId {
    final id = widget.chatId?.trim();
    return id != null && id.isNotEmpty;
  }

  bool get _isProChat =>
      widget.chatType?.trim().toLowerCase() == 'ask_pro';

  @override
  void initState() {
    super.initState();
    if (_hasChatId) {
      final chatId = widget.chatId!.trim();
      _lastMessageCount = 0;
      _controller.clearChatHistory();
      _controller.setActiveChat(
        chatId,
        receiverId: widget.otherUserId,
        otherUserImage: widget.otherUserImage,
      );
      _controller.markChatAsRead(chatId);
      _controller.fetchChatHistory(chatId);
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        final maxExtent = _scrollController.position.maxScrollExtent;
        if (maxExtent <= 0) return;

        if (animate) {
          _scrollController.animateTo(
            maxExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(maxExtent);
        }
      });
    });
  }

  void _scheduleScrollOnNewMessages(int messageCount) {
    if (messageCount == _lastMessageCount) return;

    final shouldAnimate = _lastMessageCount > 0;
    _lastMessageCount = messageCount;
    _scrollToBottom(animate: shouldAnimate);
  }

  EdgeInsets get _listPadding => EdgeInsets.only(
        left: AppPadding.padding12,
        right: AppPadding.padding12,
        bottom: 20.h,
      );

  @override
  void dispose() {
    _scrollController.dispose();
    if (_hasChatId) {
      _controller.clearActiveChat();
    }
    messageController.dispose();
    super.dispose();
  }

  String? get _currentUserId => AuthController.i.user.value?.sub?.trim();

  void _pickAndSendImage(File file) {
    _controller.sendChatImage(file);
  }

  void _openImagePicker() {
    AppDialogs.showImageSourceDialog(
      context,
      setFile: _pickAndSendImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.otherUserName?.trim().isNotEmpty == true
        ? widget.otherUserName!.trim()
        : AppStrings.dummyName;

    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: () => Get.back(),
      title: _isProChat ? null : userName,
      titleWidget: _isProChat ? _proChatTitle(userName) : null,
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
              child: Obx(
                () => Row(
                  children: [
                    Expanded(child: _messageTextField()),
                    10.horizontalSpace,
                    GestureDetector(
                      onTap: _hasChatId &&
                              !_controller.isSendingChatImage.value
                          ? _openImagePicker
                          : null,
                      child: Opacity(
                        opacity: _controller.isSendingChatImage.value
                            ? 0.5
                            : 1,
                        child: Image.asset(
                          AssetPath.cameraIcon,
                          width: 30.w,
                          height: 30.h,
                        ),
                      ),
                    ),
                    10.horizontalSpace,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _proChatTitle(String userName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: CustomText(
            text: userName,
            fontSize: 20.sp,
            maxLines: 1,
          ),
        ),
        6.horizontalSpace,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: CustomText(
            text: 'Pro',
            color: AppColors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Obx(() {
      final isLoading = _controller.isChatHistoryLoading.value;
      final messages = _controller.chatHistory;
      _scheduleScrollOnNewMessages(messages.length);

      if (isLoading && messages.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        );
      }

      if (messages.isEmpty) {
        return const EmptyMessage(message: AppStrings.noChatsFound);
      }

      return ListView.separated(
        controller: _scrollController,
        padding: _listPadding,
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
                text: current.hasImage
                    ? ''
                    : (current.displayContent.isNotEmpty
                        ? current.displayContent
                        : '-'),
                imagePath:
                    current.hasImage ? current.displayFilePath : null,
                isSender: !current.isSentBy(_currentUserId),
                profileImage: _controller.resolveSenderProfileImage(current),
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
      controller: _scrollController,
      padding: _listPadding,
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
        final text = messageController.text.trim();
        if (text.isEmpty) return;

        if (_hasChatId) {
          _controller.sendChatMessage(text);
          messageController.clear();
          return;
        }

        setState(() {
          _localMessages.add(
            ChatModel(
              text: text,
              isSender: true,
              time: DateTime.now().toUtc(),
            ),
          );
          messageController.clear();
        });
        _scrollToBottom();
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
