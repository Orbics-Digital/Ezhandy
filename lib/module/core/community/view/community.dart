import 'package:ezhandy_user/module/core/chat/routing_arguments/chat_routing_arguments.dart';
import 'package:ezhandy_user/module/core/community/controller/community_controller.dart';
import 'package:ezhandy_user/module/core/community/model/community_post_model.dart';
import 'package:ezhandy_user/module/core/community/model/reaction_model.dart';
import 'package:ezhandy_user/module/core/main_menu/main_menu_provider.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/display_helper.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/button_widgets/reaction_button.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/profile_widget/user_image_widget.dart';
import 'package:ezhandy_user/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/Slideable/slideable.dart';
import 'package:ezhandy_user/widgets/dropdown/custom_dropdown.dart';
import 'package:ezhandy_user/widgets/notification/notification_badge_icon.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
//

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityController _controller = Get.find<CommunityController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.fetchPosts();
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
          16.verticalSpace,

          Expanded(
            child: Obx(
              () {
                final items = _controller.filteredPosts;
                final isLoading = _controller.isLoading.value;

                if (!isLoading && items.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: _controller.refreshPosts,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: AppPadding.padding25),
                      children: const [
                        SizedBox(height: 120),
                        EmptyMessage(
                          message: AppStrings.noCommunityPostsFound,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.orange,
                  onRefresh: _controller.refreshPosts,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: AppPadding.padding25),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final post = items[index];
                      return singleWidget(
                        postId: post.id,
                        myReaction: post.myReaction,
                        commentCount: Constants.formatFacebookCount(
                          post.commentCount,
                        ),
                        likeCount: Constants.formatFacebookCount(
                          post.reactionCounts.total,
                        ),
                        day: _formatDate(post.createdAt),
                        name: DisplayHelper.displayValue(post.user?.fullName),
                        des: DisplayHelper.displayValue(post.description),
                        image: post.user?.profileImage,
                        postImage: post.image,
                        onTapComment: () {
                          if (post.id == null) return;
                          AppDialogs.showCommunityCommentsDialog(
                            context,
                            postId: post.id!,
                            reactionTotal: post.reactionCounts.total,
                          );
                        },
                        onReactionSelected: (reactionType) {
                          if (post.id == null) return;
                          _controller.reactToPost(
                            postId: post.id!,
                            reactionType: reactionType,
                          );
                        },
                        ontapLike: () {
                          if (post.id == null) return;
                          AppDialogs.showCommunityLikeDialog(
                            context,
                            postId: post.id!,
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return 10.verticalSpace;
                    },
                  ),
                );
              },
            ),
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
      onchange: _controller.setSearchQuery,
      inputFormatters: [LengthLimitingTextInputFormatter(35)],
    );
  }

  Row appbarWidget() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          text: AppStrings.community,
          // fontFamily: AppStrings.montserrat,
          // color: AppColors.blueDark,
          fontWeight: FontWeight.w500,
          fontSize: 20.sp,
        ),
        Spacer(),
        const NotificationBadgeIcon(),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy - hh:mm a').format(date.toLocal());
  }

  Widget singleWidget({
    String? postId,
    String? myReaction,
    day,
    name,
    image,
    postImage,
    des,
    ontapLike,
    onTapComment,
    void Function(String reactionType)? onReactionSelected,
    likeCount,
    commentCount,
  }) {
    return CustomContainer(
      // onTap: ontap,
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
        if (postImage != null && postImage.toString().isNotEmpty) ...[
          10.verticalSpace,
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              postImage,
              width: double.infinity,
              height: 180.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
        10.verticalSpace,
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [

              //     const SizedBox(width: 6),
              //     const Text(
              //       "15.5K",
              //       style: TextStyle(
              //         fontSize: 12,
              //         color: Colors.grey,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ],
              // ),

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

                    // 5.horizontalSpace,
                    CustomText(
                        text: likeCount,
                        color: AppColors.greyLight,
                        fontSize: 10.sp),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: onTapComment,
                child: CustomText(
                  text: "$commentCount Comment",
                  color: AppColors.greyLight,
                  fontSize: 10.sp,
                ),
              ),
            ]),
        Divider(),
        Row(
          children: [
            // InkWell(
            //   onTap: () {
            //     // LIKE CLICK
            //     print("Like clicked");
            //   },
            //   child: Row(
            //     children: [
            //       Icon(
            //         Icons.thumb_up_off_alt,
            //         size: 15.sp,
            //         color: AppColors.greyLight,
            //       ),
            //       5.horizontalSpace,
            //       CustomText(
            //         text: "Like",
            //         color: AppColors.greyLight,
            //         fontSize: 10.sp,
            //       ),
            //     ],
            //   ),
            // ),
            FacebookReactionButton(
              communityMode: true,
              selectedReactionType: myReaction,
              onReactionSelected: onReactionSelected,
            ),

            const Spacer(),
            GestureDetector(
              onTap: onTapComment,
              child: Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 15.sp,
                    color: AppColors.greyLight,
                  ),
                  5.horizontalSpace,
                  CustomText(
                    text: "Comment",
                    color: AppColors.greyLight,
                    fontSize: 10.sp,
                  ),
                ],
              ),
            ),
          ],
        )
      ]),
    );
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



}
