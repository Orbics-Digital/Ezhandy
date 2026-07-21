import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/core/rating_review_report/data/ratings_repository.dart';
import 'package:ezhandy_user/module/core/rating_review_report/model/provider_rating_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:get/get.dart';

class RatingsController extends GetxController {
  static RatingsController get i {
    if (!Get.isRegistered<RatingsController>()) {
      Get.put(RatingsController(), permanent: true);
    }
    return Get.find<RatingsController>();
  }

  final RatingsRepository _repository = RatingsRepository();

  final RxList<ProviderRatingModel> ratings = <ProviderRatingModel>[].obs;
  final RxBool isLoading = false.obs;

  double get averageRating {
    if (ratings.isEmpty) return 0;

    final total = ratings.fold<int>(
      0,
      (sum, item) => sum + (item.rating ?? 0),
    );
    return total / ratings.length;
  }

  String get averageRatingDisplay => averageRating.toStringAsFixed(1);

  int get totalReviews => ratings.length;

  List<RatingBreakdownItem> get ratingBreakdown {
    final counts = <int, int>{for (var star = 1; star <= 5; star++) star: 0};

    for (final item in ratings) {
      final star = item.rating;
      if (star != null && star >= 1 && star <= 5) {
        counts[star] = (counts[star] ?? 0) + 1;
      }
    }

    final total = ratings.length;
    return [
      for (final star in [5, 4, 3, 2, 1])
        RatingBreakdownItem(
          star: star,
          count: counts[star] ?? 0,
          percent: total == 0 ? 0 : (counts[star] ?? 0) / total,
        ),
    ];
  }

  List<ProviderRatingModel> get sortedRatings {
    final items = ratings.toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    return items;
  }

  Future<void> fetchProviderRatings() async {
    if (isLoading.value) return;

    final providerId = AuthController.i.user.value?.sub?.trim();
    if (providerId == null || providerId.isEmpty) {
      ratings.clear();
      AppDialogs.showToast(message: 'Provider not found');
      return;
    }

    isLoading.value = true;
    try {
      final result = await _repository.getProviderRatings(providerId);
      ratings.assignAll(result);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProviderRatings() async {
    final providerId = AuthController.i.user.value?.sub?.trim();
    if (providerId == null || providerId.isEmpty) {
      ratings.clear();
      return;
    }

    try {
      final result = await _repository.getProviderRatings(providerId);
      ratings.assignAll(result);
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }
}

class RatingBreakdownItem {
  final int star;
  final int count;
  final double percent;

  const RatingBreakdownItem({
    required this.star,
    required this.count,
    required this.percent,
  });
}
