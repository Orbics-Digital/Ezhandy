import 'dart:io';

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
  final RxBool isSubmittingProduct = false.obs;

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

  Future<bool> addProduct({
    required String title,
    required String description,
    required String price,
    required String categoryId,
    required List<File> images,
  }) async {
    if (isSubmittingProduct.value) return false;

    isSubmittingProduct.value = true;
    try {
      await _repository.createProduct(
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        images: images,
      );
      await refreshMyProducts();
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isSubmittingProduct.value = false;
    }
  }

  Future<bool> editProduct({
    required String productId,
    required String title,
    required String description,
    required String price,
    required String categoryId,
    List<File> images = const [],
    bool isActive = true,
  }) async {
    if (isSubmittingProduct.value) return false;

    isSubmittingProduct.value = true;
    try {
      await _repository.updateProduct(
        productId: productId,
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        images: images,
        isActive: isActive,
      );
      await refreshMyProducts();
      await refreshProducts();
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    } finally {
      isSubmittingProduct.value = false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      myProducts.removeWhere((product) => product.id == productId);
      products.removeWhere((product) => product.id == productId);
      return true;
    } on DioException catch (e) {
      AppDialogs.showToast(message: ApiHelper.errorMessage(e));
      return false;
    } catch (e) {
      AppDialogs.showToast(message: e.toString());
      return false;
    }
  }
}
