import 'package:ezhandy_user/module/core/community/controller/community_controller.dart';
import 'package:ezhandy_user/module/core/community/model/reaction_model.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/display_helper.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/profile_widget/user_image_widget.dart';
import 'package:ezhandy_user/widgets/toast_dialogs_sheet/custom_community_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class CommunityLikeDialog extends StatefulWidget {
  const CommunityLikeDialog({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<CommunityLikeDialog> createState() => _CommunityLikeDialogState();
}

class _CommunityLikeDialogState extends State<CommunityLikeDialog> {
  final CommunityController _controller = Get.find<CommunityController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchReactions(widget.postId);
  }

  @override
  void dispose() {
    _controller.clearReactions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCommunityDialog(
      title: "People Who Reacted",
      child: Obx(
        () {
          if (_controller.isReactionsLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            );
          }

          final counts = _controller.reactionModalCounts.value;
          final items = _controller.filteredPostReactions;
          final selectedFilter = _controller.reactionFilter.value;

          return Column(
            children: [
              SizedBox(
                height: 50,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _statItem(
                        label: 'All ${Constants.formatFacebookCount(counts?.all ?? 0)}',
                        isSelected: selectedFilter == 'all',
                        onTap: () => _controller.setReactionFilter('all'),
                      ),
                      _verticalDivider(),
                      _statItem(
                        icon: Icons.thumb_up,
                        iconColor: Colors.blue,
                        label: Constants.formatFacebookCount(counts?.thumb ?? 0),
                        isSelected: selectedFilter == CommunityReactionTypes.thumb,
                        onTap: () =>
                            _controller.setReactionFilter(CommunityReactionTypes.thumb),
                      ),
                      _verticalDivider(),
                      _statItem(
                        icon: Icons.favorite,
                        iconColor: Colors.red,
                        label: Constants.formatFacebookCount(counts?.heart ?? 0),
                        isSelected: selectedFilter == CommunityReactionTypes.heart,
                        onTap: () =>
                            _controller.setReactionFilter(CommunityReactionTypes.heart),
                      ),
                      _verticalDivider(),
                      _statItem(
                        icon: Icons.emoji_emotions,
                        iconColor: Colors.orange,
                        label: Constants.formatFacebookCount(counts?.smile ?? 0),
                        isSelected: selectedFilter == CommunityReactionTypes.smile,
                        onTap: () =>
                            _controller.setReactionFilter(CommunityReactionTypes.smile),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: EmptyMessage(
                          message: AppStrings.noReactionsFound,
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(
                          top: AppPadding.padding20,
                          bottom: AppPadding.padding25,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final reaction = items[index];
                          final reactionUi = CommunityReactionTypes.fromType(
                            reaction.reactionType,
                          );

                          return Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  UserImageWidget(
                                    image: reaction.user?.profileImage,
                                    size: 20.sp,
                                  ),
                                  if (reactionUi != null)
                                    Positioned(
                                      bottom: -5,
                                      left: 0,
                                      right: 0,
                                      child: Icon(
                                        reactionUi.icon,
                                        color: reactionUi.color,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                              5.horizontalSpace,
                              Expanded(
                                child: CustomText(
                                  text: DisplayHelper.displayValue(
                                    reaction.user?.fullName,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statItem({
    IconData? icon,
    Color? iconColor,
    required String label,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                color: iconColor ?? Colors.grey,
                size: 16,
              ),
            if (icon != null) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.orange : Colors.grey,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 18,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
