// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:ezhandy_user/utils/app_colors.dart';
// import 'package:ezhandy_user/utils/app_dialogs.dart';
// import 'package:ezhandy_user/utils/app_padding.dart';
// import 'package:ezhandy_user/utils/app_strings.dart';
// import 'package:ezhandy_user/utils/asset_path.dart';
// import 'package:ezhandy_user/utils/routes/app_navigation.dart';
// import 'package:ezhandy_user/utils/routes/app_route.dart';
// import 'package:ezhandy_user/widgets/Container/custom_container.dart';
// import 'package:ezhandy_user/widgets/button_widgets/custom_button.dart';
// import 'package:ezhandy_user/widgets/logo_and_backgrounds/background.dart';
// import 'package:ezhandy_user/widgets/row/two_text_row.dart';

// class SubscriptionSetting extends StatefulWidget {
//   SubscriptionSetting({super.key});

//   @override
//   _SubscriptionSettingState createState() => _SubscriptionSettingState();
// }

// class _SubscriptionSettingState extends State<SubscriptionSetting> {
//   @override
//   Widget build(BuildContext context) {
//     return BackgroundImage(
//       // is_registration: widget.isRegistration,
//       leading: AssetPath.backIcon,
//       onclickLead: () {
//         Get.back();
//       },
//       title: AppStrings.subscriptionSetting,

//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: AppPadding.padding12),
//         child: Column(
//           children: [
//             // 10.verticalSpace,
//             CustomContainer(
//                 child: Column(
//               children: [
//                 TwoTextRow(
//                     firstText: AppStrings.planName, secondText: "Monthly"),
//                 10.verticalSpace,
//                 TwoTextRow(
//                     firstText: AppStrings.amount,
//                     secondText: AppStrings.dummyAmount),
//                 10.verticalSpace,
//                 TwoTextRow(
//                     firstText: AppStrings.purchasedDate,
//                     secondText: AppStrings.dummyDate),
//                 10.verticalSpace,
//                 TwoTextRow(
//                     firstText: AppStrings.expiryDate,
//                     secondText: AppStrings.dummyDate),
//                 10.verticalSpace,
//                 cancelBtnWidget(context),
//               ],
//             )),

//             30.verticalSpace,
//             // 20.verticalSpace,
//             logsBtnWidget(context),
//             20.verticalSpace,
//             upgradeBtnWidget(context),

//             25.verticalSpace
//           ],
//         ),
//       ),
//     );
//   }

//   Widget cancelBtnWidget(BuildContext context) {
//     return CustomButton(
//       onclick: () {
//         AppDialogs.showSuccessDialog(
//           context,
//           description: AppStrings.cancelSubscriptionText,
//           title: AppStrings.cancelSubscription,
//           image: AssetPath.alertIcon,
//           isDoneShow: false,
//           btnTxt1: AppStrings.no,
//           onTap1: () {
//             AppNavigation.navigatorPop(context);
//           },
//           btnTxt2: AppStrings.yes,
//           onTap2: () {
//             AppNavigation.navigatorPopUntil(
//                 context, AppRoutes.mainMenuScreenRoute);
//           },
//         );
//       },
//       text: AppStrings.cancelSubscription,
//     );
//   }

//   Widget logsBtnWidget(BuildContext context) {
//     return CustomButton(
//       onclick: () {
//         AppNavigation.navigateTo(context, AppRoutes.subscriptionLogScreenRoute);
//         // AppDialogs.showSuccessDialog(
//         //   context,
//         //   description: AppStrings.paymentSuccessful,
//         //   title: AppStrings.thankYou,
//         //   btnTxt1: AppStrings.done,
//         //   onTap1: () {
//         //     AppNavigation.navigatorPopUntil(
//         //         context, AppRoutes.mainMenuScreenRoute);
//         //   },
//         // );
//       },
//       color: AppColors.blueDark,
//       text: AppStrings.subscriptionLogs,
//     );
//   }

//   Widget upgradeBtnWidget(BuildContext context) {
//     return CustomButton(
//       onclick: () {
//         AppNavigation.navigateTo(context, AppRoutes.subscriptionScreenRoute);
//         // AppDialogs.showSuccessDialog(
//         //   context,
//         //   description: AppStrings.paymentSuccessful,
//         //   title: AppStrings.thankYou,
//         //   btnTxt1: AppStrings.done,
//         //   onTap1: () {
//         //     AppNavigation.navigatorPopUntil(
//         //         context, AppRoutes.mainMenuScreenRoute);
//         //   },
//         // );
//       },
//       text: AppStrings.upgradeYourPlan,
//     );
//   }
// }
