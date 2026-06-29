import 'package:bot_toast/bot_toast.dart';
import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/storage/session_storage.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/core/controller/home_controller.dart';
import 'package:ezhandy_user/module/core/booking/controller/bookings_controller.dart';
import 'package:ezhandy_user/module/core/categories/controller/categories_controller.dart';
import 'package:ezhandy_user/module/core/community/controller/community_controller.dart';
import 'package:ezhandy_user/module/core/products/controller/products_controller.dart';
import 'package:ezhandy_user/module/core/notification/controller/notification_controller.dart';
import 'package:ezhandy_user/utils/routes/app_router.dart';
import 'package:ezhandy_user/utils/app_colors.dart';
import 'package:ezhandy_user/utils/app_size.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/keyboard_dismiss_overser.dart';
import 'package:ezhandy_user/utils/scroll_view.dart';
import 'package:ezhandy_user/utils/system_ui_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ApiClient(), permanent: true);
  Get.put(SessionStorage(), permanent: true);
  await SessionStorage.i.init();
  Get.put(AuthController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(NotificationController(), permanent: true);
  Get.put(CommunityController(), permanent: true);
  Get.put(CategoriesController(), permanent: true);
  Get.put(ProductsController(), permanent: true);
  Get.put(BookingsController(), permanent: true);
  await AuthController.i.restoreSession();
  await CategoriesController.i.initCategories();
  await NotificationController.i.fetchUnreadCount();

  AppSystemUi.applyDarkContent();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  static const MaterialColor customColor = MaterialColor(
    0xFFC52D83,
    <int, Color>{
      50: Color(0xFFFFE3EC),
      100: Color(0xFFFFB3CF),
      200: Color(0xFFFF80AF),
      300: Color(0xFFFF4D8F),
      400: Color(0xFFFF2676),
      500: Color(0xFFC52D83),
      600: Color(0xFFB82878),
      700: Color(0xFFA22468),
      800: Color(0xFF8C1F58),
      900: Color(0xFF6C1740),
    },
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize:
            const Size(AppSize.fullScreenWidth, AppSize.fullScreenHeight),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final botToastBuilder = BotToastInit();
          return GetMaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            // home: MainMenu(
            //   selectedTab: 0,
            // ),
            // initialRoute: "/",
            // getPages: AppPages.routes,
            onGenerateRoute: AppRouter.onGenerateRoute,

            theme: ThemeData(
                useMaterial3: false,
                scaffoldBackgroundColor: AppColors.white,
                fontFamily: AppStrings.montserrat,
                primarySwatch: customColor,
                unselectedWidgetColor: AppColors.transparent,
                colorScheme: ColorScheme.fromSwatch()
                    .copyWith(primary: AppColors.orange),
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: AppSystemUi.darkContent,
                )),
            navigatorObservers: [
              KeyboardDismissObserver(),
              BotToastNavigatorObserver()
            ],
            navigatorKey: Constants.navigatorKey,
            builder: (context, child) {
              child = botToastBuilder(context, child);
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: AppSystemUi.darkContent,
                sized: false,
                child: ScrollConfiguration(
                    behavior: MyScrollBehavior(),
                    child: MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: TextScaler.linear(1.0)),
                        child: child)),
              );
            },
          );
        });
  }
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }
