import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/auth/model/certificate_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_padding.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/display_helper.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
import 'package:ezhandy_user/widgets/empty_state/empty_message.dart';
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
              child: Obx(() {
              final user = AuthController.i.user.value;
              return Column(
                children: [
                  20.verticalSpace,
                  profileWidget(user?.profileImage),
                  20.verticalSpace,
                  TwoTextRow(
                    secondColor: AppColors.black,
                    firstText: AppStrings.fullName,
                    secondText: DisplayHelper.displayValue(user?.fullName),
                  ),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  TwoTextRow(
                    secondColor: AppColors.black,
                    firstText: AppStrings.phoneNumber,
                    secondText: DisplayHelper.displayValue(user?.mobileNumber),
                  ),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  TwoTextRow(
                    secondColor: AppColors.black,
                    firstText: AppStrings.emailAddress,
                    secondText: DisplayHelper.displayValue(user?.email),
                  ),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  TwoTextRow(
                    secondColor: AppColors.black,
                    firstText: AppStrings.language,
                    secondText: DisplayHelper.displayValue(user?.languageTitle),
                  ),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  TwoTextRow(
                    secondColor: AppColors.black,
                    firstText: AppStrings.gender,
                    secondText: DisplayHelper.displayValue(
                      user?.genderTitle ?? user?.gender,
                    ),
                  ),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  certificateSection(user?.certifications ?? const []),
                  10.verticalSpace,

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
              );
            }),
            )));
  }

  ProfilePictureWidget profileWidget(String? profileImageUrl) {
    return ProfilePictureWidget(
      is_pickImage: false,
      profileImageUrl: profileImageUrl,
      assetPath: AssetPath.tempImage1,
    );
  }

  Widget certificateSection(List<CertificateModel> certificates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: AppStrings.certificateDetails,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
        10.verticalSpace,
        if (certificates.isEmpty)
          const EmptyMessage(message: AppStrings.noCertificatesFound)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: certificates.length,
            itemBuilder: (context, index) {
              final item = certificates[index];
             
              return Column(
                children: [
                  TwoTextRow(
                    secondColor: AppColors.black,
                    firstText: AppStrings.insituteName,
                    secondText:
                        DisplayHelper.displayValue(item.institutionName),
                  ),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  TwoTextRow(
                    secondColor: AppColors.black,
                    firstText: AppStrings.certificateTitle,
                    secondText:
                        DisplayHelper.displayValue(item.certificationTitle),
                  ),
                  Divider(color: AppColors.blueDark),
                  10.verticalSpace,
                  CustomText(text: AppStrings.certificatePicture),
                  10.verticalSpace,
                  if (item.certificatePath != null &&
                      item.certificatePath!.isNotEmpty)
                    Image.network(
                      item.certificatePath!,
                      fit: BoxFit.cover,
                      height: 180.h,
                      width: 1.sw,
                    )
                  else
                    CustomText(
                      text: DisplayHelper.displayValue(null),
                      color: AppColors.grey,
                    ),
                  if (index < certificates.length - 1) 20.verticalSpace,
                ],
              );
            },
          ),
      ],
    );
  }
}
