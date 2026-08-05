import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/core/notification/firebase_messaging_service.dart';
import 'package:ezhandy_user/core/socket/socket_service.dart';
import 'package:ezhandy_user/core/storage/session_storage.dart';
import 'package:ezhandy_user/module/auth/data/auth_repository.dart';
import 'package:ezhandy_user/module/auth/model/register_provider_params.dart';
import 'package:ezhandy_user/module/auth/model/user_model.dart';
import 'package:ezhandy_user/module/auth/verification/routing_arguments/otp_verification_routing_arguments.dart';
import 'package:ezhandy_user/module/core/home/data/provider_services_repository.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:ezhandy_user/module/core/notification/controller/notification_controller.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_loader.dart';
import 'package:ezhandy_user/utils/app_strings.dart';
import 'package:ezhandy_user/utils/asset_path.dart';
import 'package:ezhandy_user/utils/constant.dart';
import 'package:ezhandy_user/utils/routes/app_navigation.dart';
import 'package:ezhandy_user/utils/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get i => Get.find();

  final AuthRepository _authRepository = AuthRepository();
  final ProviderServicesRepository _providerServicesRepository =
      ProviderServicesRepository();

  @override
  void onInit() {
    super.onInit();
    ApiClient.i.onUnauthorized = forceLogoutDueToUnauthorized;
  }
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoginLoading = false.obs;
  final RxBool isRegisterLoading = false.obs;
  final RxBool isLogoutLoading = false.obs;
  final RxBool isDeleteAccountLoading = false.obs;
  final RxBool isForgotPasswordLoading = false.obs;
  final RxBool isVerifyResetOtpLoading = false.obs;
  final RxBool isVerifyEmailOtpLoading = false.obs;
  final RxBool isResendVerificationLoading = false.obs;
  final RxBool isResetPasswordLoading = false.obs;
  final RxBool isChangePasswordLoading = false.obs;
  final RxBool isQuickProviderLoading = false.obs;
  final RxBool isLoginSignUp = true.obs;
  final RxBool isUpdateProfileLoading = false.obs;
  final RxBool isAddCertificationLoading = false.obs;
  final RxBool isDeleteCertificationLoading = false.obs;

  String get userDisplayName {
    final name = user.value?.fullName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user.value?.email?.trim();
    if (email != null && email.isNotEmpty) return email;

    return AppStrings.dummyName;
  }

  String get userHandle {
    final email = user.value?.email?.trim();
    if (email != null && email.contains('@')) {
      return '@${email.split('@').first}';
    }
    return '';
  }

  Future<bool> updateIsQuickProvider(bool value) async {
    final current = user.value;
    final providerId = current?.sub?.trim();
    if (current == null || providerId == null || providerId.isEmpty) {
      AppDialogs.showToast(message: 'Unable to update urgent services.');
      return false;
    }
    if (isQuickProviderLoading.value) return false;

    final previous = current.isQuickProvider;
    isQuickProviderLoading.value = true;

    user.value = current.copyWith(isQuickProvider: value);

    try {
      final isQuickProvider =
          await _providerServicesRepository.toggleQuickProvider(
        providerId: providerId,
        isQuickProvider: value,
      );
      final updated = current.copyWith(isQuickProvider: isQuickProvider);
      user.value = updated;

      final session = await SessionStorage.i.load();
      if (session != null) {
        await SessionStorage.i.save(token: session.token, user: updated);
      }
      return true;
    } on DioException catch (e) {
      user.value = current.copyWith(isQuickProvider: previous);
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      user.value = current.copyWith(isQuickProvider: previous);
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isQuickProviderLoading.value = false;
    }
  }

  Future<void> restoreSession() async {
    final session = await SessionStorage.i.load();
    if (session != null) {
      user.value = session.user;
    }
  }

  Future<void> markSubscriptionActive() async {
    final current = user.value;
    if (current == null) return;

    final updated = current.copyWith(isSubscription: true);
    user.value = updated;

    final session = await SessionStorage.i.load();
    if (session != null) {
      await SessionStorage.i.save(token: session.token, user: updated);
    }
  }

  Future<bool> fetchProfileDetails() async {
    try {
      final profile = await _authRepository.getProfileDetails();
      user.value = profile;

      final session = await SessionStorage.i.load();
      if (session != null) {
        await SessionStorage.i.save(token: session.token, user: profile);
      }
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
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
      final fcmToken = await FirebaseMessagingService.instance.getStoredToken();
      final result = await _authRepository.login(
        email: email.trim(),
        password: password,
        fcmToken: fcmToken,
      );

      if (result.requiresEmailVerification) {
        await SessionStorage.i.clear();
        user.value = null;

        if (context.mounted) {
          if (result.message != null && result.message!.trim().isNotEmpty) {
            AppDialogs.showToast(message: result.message!);
          }
          AppNavigation.navigateTo(
            context,
            AppRoutes.otpVerificationScreenRoute,
            arguments: OtpVerificationRoutingArgument(
              type: OtpType.signup.name,
              text: email.trim(),
              emailAndPhone: OtpCodeType.email.name,
            ),
          );
        }
        return true;
      }

      final token = result.token;
      final loggedInUser = result.user;
      if (token == null || token.isEmpty || loggedInUser == null) {
        AppDialogs.showToast(message: 'Login failed. Please try again.');
        return false;
      }

      await SessionStorage.i.save(token: token, user: loggedInUser);
      user.value = loggedInUser;
      isLoginSignUp.value = true;

      await NotificationController.i.fetchUnreadCount();
      await SocketService.i.connect();

      if (context.mounted) {
        AppNavigation.navigateToRemovingAll(
          context,
          loggedInUser.isSubscription
              ? AppRoutes.mainMenuScreenRoute
              : AppRoutes.subscriptionScreenRoute,
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

  Future<bool> registerProvider(
    BuildContext context, {
    required RegisterProviderParams params,
  }) async {
    if (isRegisterLoading.value) return false;

    isRegisterLoading.value = true;
    try {
      await _authRepository.registerProvider(params);

      if (context.mounted) {
        AppNavigation.navigateReplacementNamed(
          context,
          AppRoutes.otpVerificationScreenRoute,
          arguments: OtpVerificationRoutingArgument(
            type: OtpType.signup.name,
            text: params.email.trim(),
            emailAndPhone: OtpCodeType.email.name,
          ),
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
      isRegisterLoading.value = false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    if (isForgotPasswordLoading.value) return false;

    isForgotPasswordLoading.value = true;
    try {
      await _authRepository.forgotPassword(email: email.trim());
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  Future<bool> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    if (isVerifyResetOtpLoading.value) return false;

    isVerifyResetOtpLoading.value = true;
    try {
      await _authRepository.verifyResetOtp(
        email: email.trim(),
        otp: otp.trim(),
      );
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isVerifyResetOtpLoading.value = false;
    }
  }

  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    if (isVerifyEmailOtpLoading.value) return false;

    isVerifyEmailOtpLoading.value = true;
    try {
      await _authRepository.verifyOtp(
        email: email.trim(),
        otp: otp.trim(),
      );
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isVerifyEmailOtpLoading.value = false;
    }
  }

  Future<bool> resendVerification({required String email}) async {
    if (isResendVerificationLoading.value) return false;

    isResendVerificationLoading.value = true;
    try {
      await _authRepository.resendVerification(email: email.trim());
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isResendVerificationLoading.value = false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String password,
  }) async {
    if (isResetPasswordLoading.value) return false;

    isResetPasswordLoading.value = true;
    try {
      await _authRepository.resetPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isResetPasswordLoading.value = false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (isChangePasswordLoading.value) return false;

    isChangePasswordLoading.value = true;
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isChangePasswordLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String gender,
    required String address,
    String? mobileNumber,
    required int languageId,
    required String aboutUs,
    int? experience,
    File? profileImage,
  }) async {
    if (isUpdateProfileLoading.value) return false;

    isUpdateProfileLoading.value = true;
    try {
      final data = await _authRepository.updateProfile(
        fullName: fullName,
        gender: gender,
        address: address,
        mobileNumber: mobileNumber,
        languageId: languageId,
        aboutUs: aboutUs,
        experience: experience,
        profileImage: profileImage,
      );

      // final profileLoaded = await fetchProfileDetails();
      // return profileLoaded;

      final updated = UserModel.fromJson(data);
      user.value = updated;

      final session = await SessionStorage.i.load();
      if (session != null) {
        await SessionStorage.i.save(token: session.token, user: updated);
      }
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isUpdateProfileLoading.value = false;
    }
  }

  Future<bool> addCertification({
    required String institutionName,
    required String certificationTitle,
    required File certificationImage,
  }) async {
    isAddCertificationLoading.value = true;
    try {
      await _authRepository.addCertification(
        institutionName: institutionName,
        certificationTitle: certificationTitle,
        certificationImage: certificationImage,
      );
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isAddCertificationLoading.value = false;
    }
  }

  Future<bool> deleteCertification(String certificationId) async {
    isDeleteCertificationLoading.value = true;
    try {
      await _authRepository.deleteCertification(certificationId);
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isDeleteCertificationLoading.value = false;
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

  void showDeleteAccountConfirmation(BuildContext context) {
    AppDialogs.showSuccessDialog(
      context,
      description: AppStrings.areYouSureWantToDeleteThisAccount,
      title: AppStrings.deleteAccount,
      image: AssetPath.alertIcon,
      isDoneShow: false,
      btnTxt1: AppStrings.no,
      onTap1: () => AppNavigation.navigatorPop(context),
      btnTxt2: AppStrings.yes,
      onTap2: () {
        AppNavigation.navigatorPop(context);
        deleteAccount(context);
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
      SocketService.i.disconnect();
      await SessionStorage.i.clear();
      user.value = null;
      NotificationController.i.clearUnreadCount();
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

  Future<void> deleteAccount(BuildContext context) async {
    if (isDeleteAccountLoading.value) return;

    isDeleteAccountLoading.value = true;
    AppLoader.show();
    try {
      await _authRepository.deleteAccount();

      SocketService.i.disconnect();
      await SessionStorage.i.clear();
      user.value = null;
      NotificationController.i.clearUnreadCount();
      AppLoader.hide();
      isDeleteAccountLoading.value = false;

      if (!context.mounted) return;

      AppDialogs.showSuccessDialog(
        context,
        description: AppStrings.accountDeleteSuccessfully,
        title: AppStrings.congratulation,
        btnTxt1: AppStrings.ok,
        onTap1: () {
          AppNavigation.navigateToRemovingAll(
            context,
            AppRoutes.loginScreenRoute,
          );
        },
      );
    } on DioException catch (e) {
      AppLoader.hide();
      isDeleteAccountLoading.value = false;
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppLoader.hide();
      isDeleteAccountLoading.value = false;
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<void> forceLogoutDueToUnauthorized() async {
    if (isLogoutLoading.value || user.value == null) return;

    isLogoutLoading.value = true;
    try {
      SocketService.i.disconnect();
      await SessionStorage.i.clear();
      user.value = null;
      NotificationController.i.clearUnreadCount();

      AppDialogs.showToast(message: 'Session expired. Please login again.');

      final context = Constants.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        AppNavigation.navigateToRemovingAll(
          context,
          AppRoutes.loginScreenRoute,
        );
      }
    } finally {
      isLogoutLoading.value = false;
    }
  }
}
