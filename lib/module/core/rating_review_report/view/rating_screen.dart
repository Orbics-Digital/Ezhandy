import 'package:ezhandy_user/module/core/rating_review_report/controller/ratings_controller.dart';
import 'package:ezhandy_user/module/core/rating_review_report/model/provider_rating_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_shadows.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/Container/custom_container.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
import 'package:ezhandy_user/widgets/indicator/percentage_indicator.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/rating_star/rating_star.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final RatingsController _controller = RatingsController.i;

  @override
  void initState() {
    super.initState();
    _controller.fetchProviderRatings();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      leading: AssetPath.backIcon,
      onclickLead: Get.back,
      title: AppStrings.reviewAndRating,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
        child: Obx(() {
          if (_controller.isLoading.value && _controller.ratings.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            );
          }

          final reviews = _controller.sortedRatings;

          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: _controller.refreshProviderRatings,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  20.verticalSpace,
                  Row(
                    children: [
                      ratingBarWidget(),
                      10.horizontalSpace,
                      avgRatingWidget(),
                    ],
                  ),
                  15.verticalSpace,
                  if (reviews.isEmpty)
                    SizedBox(
                      height: 0.45.sh,
                      child: const Center(
                        child: EmptyMessage(
                          message: AppStrings.noReviewsFound,
                        ),
                      ),
                    )
                  else
                    ...[
                      for (var i = 0; i < reviews.length; i++) ...[
                        if (i > 0) 10.verticalSpace,
                        reviewContainer(reviews[i]),
                      ],
                    ],
                  25.verticalSpace,
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  CustomContainer reviewContainer(ProviderRatingModel review) {
    return CustomContainer(
      boxShadow: AppShadows.shadow1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: review.displayUserName,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          5.verticalSpace,
          ratingWidget(initialRating: review.ratingValue),
          5.verticalSpace,
          CustomText(
            text: review.displayDate,
            fontSize: 12.sp,
            color: AppColors.greyLight,
          ),
          5.verticalSpace,
          CustomText(
            text: review.displayReview,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }

  Column ratingBarWidget() {
    final breakdown = _controller.ratingBreakdown;

    return Column(
      children: breakdown
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: ratingIndicatorWidget(
                ratNum: item.star.toString(),
                percent: item.percent,
              ),
            ),
          )
          .toList(),
    );
  }

  Column avgRatingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: _controller.averageRatingDisplay,
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.star,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
        CustomText(
          text: '${_controller.totalReviews} ${AppStrings.reviews}',
          is_alignLeft: false,
          fontSize: 10.sp,
        ),
      ],
    );
  }

  Widget ratingWidget({required double initialRating}) {
    return RatingStar(
      ignoreGestures: true,
      itemSize: 25.sp,
      initialRating: initialRating,
      onRatingUpdate: (_) {},
    );
  }

  Row ratingIndicatorWidget({
    required String ratNum,
    required double percent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomText(
          align: Alignment.topCenter,
          text: ratNum,
          is_alignLeft: false,
        ),
        10.horizontalSpace,
        SizedBox(
          width: 0.6.sw,
          child: PercentageIndicator(percent: percent),
        ),
      ],
    );
  }
}
