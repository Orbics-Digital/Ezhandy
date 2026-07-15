import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/auth/content/data/pages_repository.dart';
import 'package:ezhandy_user/module/auth/content/model/page_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/enums.dart';
import 'package:get/get.dart';

class PagesController extends GetxController {
  static PagesController get i {
    if (!Get.isRegistered<PagesController>()) {
      Get.put(PagesController(), permanent: true);
    }
    return Get.find<PagesController>();
  }

  final PagesRepository _repository = PagesRepository();

  final Rxn<PageModel> currentPage = Rxn<PageModel>();
  final RxBool isLoading = false.obs;

  static String? slugFromContentType(String? type) {
    if (type == WebContentType.ap.name) return 'about';
    if (type == WebContentType.pp.name) return 'privacy';
    if (type == WebContentType.tc.name) return 'terms';
    return null;
  }

  Future<void> fetchPage(String slug) async {
    final normalizedSlug = slug.trim();
    if (normalizedSlug.isEmpty || isLoading.value) return;

    isLoading.value = true;
    currentPage.value = null;

    try {
      currentPage.value = await _repository.getPageBySlug(normalizedSlug);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
