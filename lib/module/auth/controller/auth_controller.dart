import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/core/storage/session_storage.dart';
import 'package:ezhandy_user/module/auth/data/auth_repository.dart';
import 'package:ezhandy_user/module/auth/model/user_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_loader.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get i => Get.find();

  final AuthRepository _authRepository = AuthRepository();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoginLoading = false.obs;
  final RxBool isLogoutLoading = false.obs;
  final RxBool isLoginSignUp = true.obs;

  Future<void> restoreSession() async {
    final session = await SessionStorage.i.load();
    if (session != null) {
      user.value = session.user;
    }
  }

  Future<bool> signIn(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    if (isLoginLoading.value) return false;

    isLoginLoading.value = true;
    try {
      final result = await _authRepository.login(
        email: email.trim(),
        password: password,
      );

      await SessionStorage.i.save(token: result.token, user: result.user);
      user.value = result.user;
      isLoginSignUp.value = true;

      if (context.mounted) {
        AppNavigation.navigateToRemovingAll(
          context,
          AppRoutes.mainMenuScreenRoute,
        );
      }
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isLoginLoading.value = false;
    }
  }

  void showLogoutConfirmation(BuildContext context) {
    AppDialogs.showSuccessDialog(
      context,
      description: AppStrings.confirmationDialogLogoutDescription,
      title: AppStrings.logout,
      image: AssetPath.alertIcon,
      isDoneShow: false,
      btnTxt1: AppStrings.no,
      onTap1: () => AppNavigation.navigatorPop(context),
      btnTxt2: AppStrings.yes,
      onTap2: () {
        AppNavigation.navigatorPop(context);
        logout(context);
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    if (isLogoutLoading.value) return;

    isLogoutLoading.value = true;
    AppLoader.show();
    try {
      await _authRepository.logout();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      await SessionStorage.i.clear();
      user.value = null;
      isLogoutLoading.value = false;
      AppLoader.hide();

      if (context.mounted) {
        AppNavigation.navigateToRemovingAll(
          context,
          AppRoutes.loginScreenRoute,
        );
      }
    }
  }
}
