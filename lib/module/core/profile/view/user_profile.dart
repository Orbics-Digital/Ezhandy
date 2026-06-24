import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
import 'package:ezhandy_user/widgets/profile_widget/profile_picture_widget.dart';
import 'package:ezhandy_user/widgets/row/two_text_row.dart';
import 'package:ezhandy_user/widgets/text_widgets/text_widget.dart';
import 'package:share_plus/share_plus.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
        leading: AssetPath.backIcon,
        onclickLead: () {
          Get.back();
        },
        title: AppStrings.myProfile,
        actionWidget: GestureDetector(
          onTap: ()  async {
        await SharePlus.instance.share(
            ShareParams(text: 'check out my website https://example.com'));
        // AppNavigation.navigateToRemovingAll(
        //     context, AppRoutes.mainMenuScreenRoute);



          },
          child: Padding(
            padding: EdgeInsets.only(right:AppPadding.padding16),
            child: Column(
              children: [
                Container(
                    width: 35.w,
                    height: 35.h,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.greyLight),
                        image: DecorationImage(
                            image: AssetImage(AssetPath.shareIcon),scale: 4.5.sp))),
                CustomText(text: "Share", fontWeight: FontWeight.bold,fontSize: 12.sp,)
              ],
            ),
          ),
        ),
        appBarheight: 50,
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  20.verticalSpace,
                  profileWidget(),
                  20.verticalSpace,
                  TwoTextRow(
                      secondColor: AppColors.black,
                      firstText: AppStrings.fullName,
                      secondText: AppStrings.dummyName),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  TwoTextRow(
                      secondColor: AppColors.black,
                      firstText: AppStrings.phoneNumber,
                      secondText: AppStrings.dummyPhoneNUmber),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  TwoTextRow(
                      secondColor: AppColors.black,
                      firstText: AppStrings.emailAddress,
                      secondText: AppStrings.dummyEmail),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  TwoTextRow(
                      secondColor: AppColors.black,
                      firstText: AppStrings.language,
                      secondText: "English"),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  TwoTextRow(
                      secondColor: AppColors.black,
                      firstText: AppStrings.gender,
                      secondText: "Male"),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  CustomText(
                      text: AppStrings.certificateDetails,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp),
                  10.verticalSpace,

                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        // var item = certificates[index];
                        return Column(
                          children: [
                            TwoTextRow(
                                secondColor: AppColors.black,
                                firstText: AppStrings.insituteName,
                                secondText: "Abc institute"),
                            Divider(color: AppColors.blueDark),
                            10.verticalSpace,
                            TwoTextRow(
                                secondColor: AppColors.black,
                                firstText: AppStrings.certificateTitle,
                                secondText: "Abc Certificate"),
                            Divider(color: AppColors.blueDark),
                            10.verticalSpace,
                            CustomText(text: "Certificate Picture"),
                            10.verticalSpace,
                            Image.network(
                              "https://marketplace.canva.com/EAFGv9WhSmc/1/0/1600w/canva-blue-and-yellow-minimalist-employee-of-the-month-certificate-jaIc19nYjY4.jpg",
                              fit: BoxFit.cover,
                              height: 180.h,
                              width: 1.sw,
                            ),
                          ],
                        );
                      }),

                  // Divider(color: AppColors.blueDark),
                  // 10.verticalSpace,
                  // TwoTextRow(secondColor: AppColors.black,
                  //     firstText: AppStrings.referralCode, secondText: "Football"),
                  // Divider(color: AppColors.blueDark),
                  // 10.verticalSpace,
                  // TwoTextRow(secondColor: AppColors.black,
                  //     firstText: AppStrings.status, secondText: "High"),

                  40.verticalSpace,
                  CustomButton(
                    text: AppStrings.editProfile,
                    onclick: () {
                      AppNavigation.navigateTo(
                          context, AppRoutes.editProfileScreenRoute);
                    },
                  ),
                  20.verticalSpace,
                  GestureDetector(
                    onTap: () {
                      AppNavigation.navigateTo(
                          context, AppRoutes.changePasswordScreenRoute);
                    },
                    child: CustomText(
                        text: AppStrings.changePassword,
                        is_alignLeft: false,
                        textDecoration: TextDecoration.underline,
                        // color: AppColors.blueDark,
                        fontSize: 18.sp),
                  ),
                  20.verticalSpace,
                  GestureDetector(
                    onTap: () {
                      AppDialogs.showSuccessDialog(context,
                          description:
                              AppStrings.areYouSureWantToDeleteThisAccount,
                          title: AppStrings.deleteAccount,
                          image: AssetPath.alertIcon,
                          isDoneShow: false,
                          btnTxt1: AppStrings.no,
                          onTap1: () {
                            AppNavigation.navigatorPop(context);
                          },
                          btnTxt2: AppStrings.yes,
                          onTap2: () {
                            AppNavigation.navigatorPop(context);
                            AppDialogs.showSuccessDialog(
                              context,
                              description: AppStrings.accountDeleteSuccessfully,
                              title: AppStrings.congratulation,
                              btnTxt1: AppStrings.ok,
                              onTap1: () {
                                AppNavigation.navigateToRemovingAll(
                                    context, AppRoutes.loginScreenRoute);
                              },
                            );
                          });
                    },
                    child: CustomText(
                        text: AppStrings.deleteAccount,
                        is_alignLeft: false,
                        textDecoration: TextDecoration.underline,
                        color: AppColors.red,
                        fontSize: 18.sp),
                  ),
                  20.verticalSpace,
                  GestureDetector(
                    onTap: () {
                      AppNavigation.navigateTo(
                          context, AppRoutes.ratingScreenRoute);
                    },
                    child: CustomText(
                        text: "My Reviews",
                        is_alignLeft: false,
                        textDecoration: TextDecoration.underline,
                        color: AppColors.red,
                        fontSize: 18.sp),
                  ),
                  25.verticalSpace
                ],
              ),
            )));
  }

  ProfilePictureWidget profileWidget() {
    return ProfilePictureWidget(
      // showUpload: widget.type == ProfileType.edit.name,
      // upload_icon:
      //     args == AppStrings.CREATE_PROFILE ? false : true,
      is_pickImage: false,

      // is_pickImage:
      //     args == AppStrings.CREATE_PROFILE ? true : false,
      // setFile: _setFile,
      // profileImageUrl:
      //     AuthController.i.appUser.value.data!.profileImage,
      // profileImage: _profileImage,
      assetPath:
          // args == AppStrings.CREATE_PROFILE
          //     ? null
          // :
          AssetPath.tempImage1,
      // borderWidth:
      // args == AppStrings.CREATE_PROFILE ? null :
      // 5,
    );
  }
}
