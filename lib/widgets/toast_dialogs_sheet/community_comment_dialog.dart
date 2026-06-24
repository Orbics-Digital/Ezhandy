import 'package:ezhandy_user/module/core/community/controller/community_controller.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/display_helper.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/reaction_button.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/profile_widget/user_image_widget.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:ezhandy_user/widgets/toast_dialogs_sheet/custom_community_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class CommunityCommentsDialog extends StatefulWidget {
  const CommunityCommentsDialog({
    super.key,
    required this.postId,
    this.reactionTotal = 0,
  });

  final String postId;
  final int reactionTotal;

  @override
  State<CommunityCommentsDialog> createState() =>
      _CommunityCommentsDialogState();
}

class _CommunityCommentsDialogState extends State<CommunityCommentsDialog> {
  final CommunityController _controller = Get.find<CommunityController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.fetchComments(widget.postId);
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    _controller.clearComments();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalCount =
        Constants.formatFacebookCount(widget.reactionTotal);

    return CustomCommunityDialog(
        title: "Comments",
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 30.w,
                      height: 20,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _staticReactionIcon(
                            icon: Icons.thumb_up,
                            color: Colors.blue,
                            left: 0,
                          ),
                          _staticReactionIcon(
                            icon: Icons.favorite,
                            color: Colors.red,
                            left: 8,
                          ),
                          _staticReactionIcon(
                            icon: Icons.emoji_emotions,
                            color: Colors.orange,
                            left: 15,
                          ),
                        ],
                      ),
                    ),
                    CustomText(
                        text: totalCount,
                        color: AppColors.greyLight,
                        fontSize: 10.sp),
                  ],
                ),
                FacebookReactionButton(
                  onTap: () {},
                ),
              ],
            ),
            Expanded(
              child: Obx(
                () {
                  if (_controller.isCommentsLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orange,
                      ),
                    );
                  }

                  final items = _controller.comments;
                  if (items.isEmpty) {
                    return const Center(
                      child: EmptyMessage(
                        message: AppStrings.noCommentsFound,
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                        top: AppPadding.padding20,
                        bottom: AppPadding.padding25),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final comment = items[index];
                      return singleWidget(
                        day: _formatDate(comment.createdAt),
                        name: DisplayHelper.displayValue(comment.user?.fullName),
                        des: DisplayHelper.displayValue(comment.text),
                        image: comment.user?.profileImage,
                        ontapLike: () {
                          AppDialogs.showCommunityLikeDialog(
                            context,
                            postId: widget.postId,
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return 10.verticalSpace;
                    },
                  );
                },
              ),
            ),
            10.verticalSpace,
            _messageTextField()
          ],
        ));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy - hh:mm a').format(date.toLocal());
  }

  Widget _messageTextField() {
    return Obx(
      () => CustomTextField(
        borderRadius: 5.r,
        borderColor: AppColors.greyBorder,
        fillColor: AppColors.transparent,
        hint: AppStrings.writeComment,
        hintColor: AppColors.greyLight,
        divider: false,
        label: false,
        readOnly: _controller.isAddingComment.value,
        sufixImage: Image.asset(
          AssetPath.sendIcon,
          width: 30.w,
          height: 30.h,
          color: AppColors.orange,
        ),
        onclickSufix: _submitComment,
        inputFormatters: [
          LengthLimitingTextInputFormatter(Constants.descriptionMaxLength)
        ],
        controller: messageController,
      ),
    );
  }

  Future<void> _submitComment() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();
    final success = await _controller.addComment(
      postId: widget.postId,
      text: text,
    );
    if (success) {
      messageController.clear();
      _scrollToBottom();
    }
  }

  Widget _staticReactionIcon({
    required IconData icon,
    required Color color,
    required double left,
  }) {
    return Positioned(
      left: left,
      child: Center(
        child: Icon(
          icon,
          size: 12,
          color: color,
        ),
      ),
    );
  }

  Widget singleWidget({
    day,
    name,
    image,
    des,
    ontapLike,
  }) {
    return CustomContainer(
      bgColor: AppColors.transparent,
      child: Column(children: [
        Row(children: [
          UserImageWidget(
            image: image,
            size: 20.sp,
          ),
          5.horizontalSpace,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomText(
                text: name, fontSize: 16.sp, fontWeight: FontWeight.bold),
            CustomText(
              text: day,
              fontSize: 12.sp,
            ),
          ]),
        ]),
        5.verticalSpace,
        CustomText(text: des),
        5.verticalSpace,
        const Divider(),
        5.verticalSpace,
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FacebookReactionButton(),
              Spacer(),
              GestureDetector(
                onTap: ontapLike,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 30.w,
                      height: 20,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _staticReactionIcon(
                            icon: Icons.thumb_up,
                            color: Colors.blue,
                            left: 0,
                          ),
                          _staticReactionIcon(
                            icon: Icons.favorite,
                            color: Colors.red,
                            left: 8,
                          ),
                          _staticReactionIcon(
                            icon: Icons.emoji_emotions,
                            color: Colors.orange,
                            left: 15,
                          ),
                        ],
                      ),
                    ),
                    CustomText(
                        text: '0',
                        color: AppColors.greyLight,
                        fontSize: 10.sp),
                  ],
                ),
              ),
            ]),
      ]),
    );
  }
}
