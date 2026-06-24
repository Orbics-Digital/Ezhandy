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
  final RxnString reactingPostId = RxnString();

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

  Future<void> reactToPost({
    required String postId,
    required String reactionType,
  }) async {
    if (reactingPostId.value == postId) return;

    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    reactingPostId.value = postId;
    try {
      final data = await _repository.addReaction(
        postId: postId,
        reactionType: reactionType,
      );

      final post = posts[index];
      final previousReaction = post.myReaction;
      final countsFromApi = _parseReactionCounts(data);
      final togglingOff = previousReaction == reactionType;

      late final String? updatedMyReaction;
      late final bool clearMyReaction;

      if (data.containsKey('myReaction')) {
        updatedMyReaction = data['myReaction']?.toString();
        clearMyReaction = data['myReaction'] == null;
      } else if (togglingOff) {
        updatedMyReaction = null;
        clearMyReaction = true;
      } else {
        updatedMyReaction = reactionType;
        clearMyReaction = false;
      }

      posts[index] = post.copyWith(
        reactionCounts: countsFromApi ??
            post.reactionCounts.applyReaction(
              previousReaction: previousReaction,
              newReaction: clearMyReaction
                  ? (previousReaction ?? reactionType)
                  : reactionType,
            ),
        myReaction: updatedMyReaction,
        clearMyReaction: clearMyReaction,
      );
      posts.refresh();
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      reactingPostId.value = null;
    }
  }

  CommunityReactionCountsModel? _parseReactionCounts(Map<String, dynamic> data) {
    final direct = data['reactionCounts'];
    if (direct is Map) {
      return CommunityReactionCountsModel.fromJson(
        Map<String, dynamic>.from(direct),
      );
    }

    final post = data['post'];
    if (post is Map && post['reactionCounts'] is Map) {
      return CommunityReactionCountsModel.fromJson(
        Map<String, dynamic>.from(post['reactionCounts'] as Map),
      );
    }

    return null;
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
