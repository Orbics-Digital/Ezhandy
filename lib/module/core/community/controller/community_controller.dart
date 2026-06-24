import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/community/data/community_repository.dart';
import 'package:ezhandy_user/module/core/community/model/community_post_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_loader.dart';
import 'package:get/get.dart';

class CommunityController extends GetxController {
  static CommunityController get i => Get.find<CommunityController>();

  final CommunityRepository _repository = CommunityRepository();

  final RxList<CommunityPostModel> posts = <CommunityPostModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  List<CommunityPostModel> get filteredPosts {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return posts.toList();

    return posts.where((post) {
      final name = post.user?.fullName?.trim().toLowerCase() ?? '';
      return name.contains(query);
    }).toList();
  }

  void setSearchQuery(String value) => searchQuery.value = value;

  Future<void> refreshPosts() async {
    try {
      posts.assignAll(await _repository.getPosts());
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<void> fetchPosts() async {
    if (isLoading.value) return;

    isLoading.value = true;
    AppLoader.show();
    try {
      posts.assignAll(await _repository.getPosts());
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isLoading.value = false;
      AppLoader.hide();
    }
  }
}
