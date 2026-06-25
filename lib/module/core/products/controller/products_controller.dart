import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/auth/controller/auth_controller.dart';
import 'package:ezhandy_user/module/core/products/data/products_repository.dart';
import 'package:ezhandy_user/module/core/products/model/product_model.dart';
import 'package:ezhandy_user/utils/app_dialogs.dart';
import 'package:get/get.dart';

class ProductsController extends GetxController {
  static ProductsController get i => Get.find<ProductsController>();

  final ProductsRepository _repository = ProductsRepository();

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> myProducts = <ProductModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isMyProductsLoading = false.obs;

  void setSearchQuery(String value) => searchQuery.value = value;

  String? get _loggedInUserId {
    final userId = AuthController.i.user.value?.sub?.trim();
    if (userId == null || userId.isEmpty) return null;
    return userId;
  }

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    final activeProducts =
        products.where((product) => product.isActive).toList();

    if (query.isEmpty) return activeProducts;

    return activeProducts.where((product) {
      final title = product.title?.trim().toLowerCase() ?? '';
      final description = product.description?.trim().toLowerCase() ?? '';
      final category =
          product.category?.title?.trim().toLowerCase() ??
          product.category?.name?.trim().toLowerCase() ??
          '';

      return title.contains(query) ||
          description.contains(query) ||
          category.contains(query);
    }).toList();
  }

  List<ProductModel> get filteredMyProducts {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return myProducts.toList();

    return myProducts.where((product) {
      final title = product.title?.trim().toLowerCase() ?? '';
      final description = product.description?.trim().toLowerCase() ?? '';
      final category =
          product.category?.title?.trim().toLowerCase() ??
          product.category?.name?.trim().toLowerCase() ??
          '';

      return title.contains(query) ||
          description.contains(query) ||
          category.contains(query);
    }).toList();
  }

  Future<void> refreshProducts() async {
    try {
      products.assignAll(await _repository.getProducts());
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<void> refreshMyProducts() async {
    final userId = _loggedInUserId;
    if (userId == null) {
      myProducts.clear();
      return;
    }

    try {
      myProducts.assignAll(await _repository.getOwnerProducts(userId));
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    }
  }

  Future<void> fetchProducts() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      products.assignAll(await _repository.getProducts());
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyProducts() async {
    final userId = _loggedInUserId;
    if (userId == null) {
      myProducts.clear();
      return;
    }
    if (isMyProductsLoading.value) return;

    isMyProductsLoading.value = true;
    try {
      myProducts.assignAll(await _repository.getOwnerProducts(userId));
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
    } finally {
      isMyProductsLoading.value = false;
    }
  }
}
