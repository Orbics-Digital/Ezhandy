import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/community/data/community_repository.dart';
import 'package:ezhandy_user/module/core/community/model/community_comment_model.dart';
import 'package:ezhandy_user/module/core/community/model/community_post_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:ezhandy_user/utils/app_loader.dart';
import 'package:get/get.dart';

class CommunityController extends GetxController {
  static CommunityController get i => Get.find<CommunityController>();

  final CommunityRepository _repository = CommunityRepository();

  final RxList<CommunityPostModel> posts = <CommunityPostModel>[].obs;
  final RxList<CommunityCommentModel> comments = <CommunityCommentModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCommentsLoading = false.obs;
  final RxBool isAddingComment = false.obs;

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

  Future<void> fetchComments(String postId) async {
    isCommentsLoading.value = true;
    comments.clear();
    try {
      comments.assignAll(await _repository.getComments(postId));
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isCommentsLoading.value = false;
    }
  }

  void clearComments() => comments.clear();

  Future<bool> addComment({
    required String postId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (isAddingComment.value) return false;

    isAddingComment.value = true;
    try {
      final comment = await _repository.addComment(
        postId: postId,
        text: trimmed,
      );
      comments.add(comment);
      _incrementPostCommentCount(postId);
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isAddingComment.value = false;
    }
  }

  void _incrementPostCommentCount(String postId) {
    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final post = posts[index];
    posts[index] = post.copyWith(commentCount: post.commentCount + 1);
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
