import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/chat/data/ask_pro_repository.dart';
import 'package:ezhandy_user/module/core/chat/model/ask_pro_request_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:get/get.dart';

class AskProController extends GetxController {
  static AskProController get i {
    if (!Get.isRegistered<AskProController>()) {
      Get.put(AskProController(), permanent: true);
    }
    return Get.find<AskProController>();
  }

  final AskProRepository _repository = AskProRepository();

  final RxList<AskProRequestModel> requests = <AskProRequestModel>[].obs;
  final RxBool isRequestsLoading = false.obs;

  Future<void> fetchRequests() async {
    if (isRequestsLoading.value) return;

    isRequestsLoading.value = true;
    try {
      final result = await _repository.getRequests();
      requests.assignAll(result);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isRequestsLoading.value = false;
    }
  }

  Future<void> refreshRequests() async {
    try {
      final result = await _repository.getRequests();
      requests.assignAll(result);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }
}
