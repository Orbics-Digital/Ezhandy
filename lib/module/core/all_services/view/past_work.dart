import 'package:ezhandy_user/module/core/all_services/routing_arguments/past_work_routing_arguments%20copy.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';

class PastWork extends StatefulWidget {
  PastWork({super.key});

  @override
  State<PastWork> createState() => _PastWorkState();
}

class _PastWorkState extends State<PastWork> {
  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        // appBarheight: 50.h,
        title: AppStrings.pastWork,
        actionWidget: actionWidget(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.padding12,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    // final item = notifications[index];
                    return singleQuestionWidget(taskDetail: AppStrings.lorem5);
                  },
                  separatorBuilder: (context, index) {
                    return 10.verticalSpace;
                  },
                ),
                25.verticalSpace,
              ],
            ),
          ),
        ));
  }

  GestureDetector actionWidget() {
    return GestureDetector(
      onTap: () {
        AppNavigation.navigateTo(
            context, AppRoutes.addEditPastWorkScreenRoute,
            arguments: PastWorkRoutingArgument(type: AddEditType.add.name));
      },
      child: Container(
          height: 40.h,
          width: 40.w,
          // padding: EdgeInsets.all(8),
          margin: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
              // boxShadow: AppShadows.shadow4,
              color: AppColors.orange,
              shape: BoxShape.circle),
          child: Icon(Icons.add)),
    );
  }

  Widget singleQuestionWidget({taskDetail}) {
    return Column(children: [
      20.verticalSpace,
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomText(
              text: "Past Work Name Title Here",
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Spacer(),
          GestureDetector(
              onTap: () {
                AppNavigation.navigateTo(
                    context, AppRoutes.addEditPastWorkScreenRoute,
                    arguments:
                        PastWorkRoutingArgument(type: AddEditType.edit.name));
              },
              child: Image.asset(
                AssetPath.editPastIcon,
                color: AppColors.grey,
                scale: 3.5.sp,
              )),
          15.horizontalSpace,
          GestureDetector(
              onTap: () {
                AppDialogs.showSuccessDialog(context,
                    description:
                        AppStrings.areYouSureYouWantToDeleteThisWorkHistory,
                    // title: AppStrings.deleteAccount,
                    image: AssetPath.deleteWithCircleIcon,
                    isDoneShow: false,
                    btnTxt1: AppStrings.yes,
                    onTap1: () {
                      AppNavigation.navigatorPop(context);
                      AppDialogs.showSuccessDialog(
                        context,
                        description: AppStrings.workHistoryDeleteSuccessfully,
                        title: AppStrings.congratulation,
                        btnTxt1: AppStrings.ok,
                        onTap1: () {
                          AppNavigation.navigatorPopUntil(
                              context, AppRoutes.pastworkScreenRoute);
                        },
                      );
                    },
                    btnTxt2: AppStrings.no,
                    onTap2: () {
                      AppNavigation.navigatorPop(context);
                    });
              },
              child: Image.asset(
                AssetPath.deletePastIcon,
                color: AppColors.grey,
                scale: 3.5.sp,
              )),
          // Image.asset(AssetPath.editIcon,color: AppColors.grey,scale: 2.sp,)
        ],
      ),
      10.verticalSpace,
      CustomText(text: taskDetail),
      10.verticalSpace,
      imageListWidget()
      // 10.verticalSpace,
      // imageListWidget(),
    ]);
  }

  Widget imageListWidget() {
    return Container(
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            width: .45.sw,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        "https://t4.ftcdn.net/jpg/02/14/20/51/360_F_214205168_JqvyKVeKzYGTpQEdy3Y1c7CUh6fRMg0W.jpg"))),
          );
        },
        separatorBuilder: (context, index) {
          return 10.horizontalSpace;
        },
        itemCount: 5,
      ),
    );
  }
}
