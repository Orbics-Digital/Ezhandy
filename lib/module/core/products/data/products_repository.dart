import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezhandy_user/core/network/api_client.dart';
import 'package:ezhandy_user/core/network/api_constants.dart';
import 'package:ezhandy_user/core/network/api_endpoints.dart';
import 'package:ezhandy_user/core/network/api_helper.dart';
import 'package:ezhandy_user/module/core/products/model/product_model.dart';

class ProductsRepository {
  ProductsRepository({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  ApiClient get _client => _apiClient ?? ApiClient.i;

  Future<List<ProductModel>> getProducts() async {
    final response = await _client.dio.get(ApiEndpoints.products);

    return ApiHelper.dataList(response.data)
        .map(ProductModel.fromJson)
        .toList();
  }

  Future<List<ProductModel>> getOwnerProducts(String ownerId) async {
    final response =
        await _client.dio.get(ApiEndpoints.ownerProducts(ownerId));

    return ApiHelper.dataList(response.data)
        .map(ProductModel.fromJson)
        .toList();
  }

  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required String price,
    required String categoryId,
    required List<File> images,
    bool isActive = true,
  }) async {
    final formData = await _buildProductFormData(
      title: title,
      description: description,
      price: price,
      categoryId: categoryId,
      images: images,
      isActive: isActive,
    );

    final response = await _client.dio.post(
      ApiEndpoints.products,
      data: formData,
      options: _multipartOptions(),
    );

    return ProductModel.fromJson(ApiHelper.dataObject(response.data));
  }

  Future<ProductModel> updateProduct({
    required String productId,
    required String title,
    required String description,
    required String price,
    required String categoryId,
    List<File> images = const [],
    bool isActive = true,
  }) async {
    final formData = await _buildProductFormData(
      title: title,
      description: description,
      price: price,
      categoryId: categoryId,
      images: images,
      isActive: isActive,
    );

    final response = await _client.dio.patch(
      ApiEndpoints.product(productId),
      data: formData,
      options: _multipartOptions(),
    );

    return ProductModel.fromJson(ApiHelper.dataObject(response.data));
  }

  Future<void> deleteProduct(String productId) async {
    final response = await _client.dio.delete(ApiEndpoints.product(productId));
    final data = response.data;

    if (data is! Map) return;

    final root = Map<String, dynamic>.from(data);
    if (!ApiHelper.isSuccessResponse(root)) {
      throw Exception(ApiHelper.responseMessage(root) ?? 'Request failed');
    }
  }

  Future<FormData> _buildProductFormData({
    required String title,
    required String description,
    required String price,
    required String categoryId,
    required List<File> images,
    required bool isActive,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'isActive': isActive,
    });

    for (final image in images) {
      final fileName = image.path.split(Platform.pathSeparator).last;
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            image.path,
            filename: fileName,
          ),
        ),
      );
    }

    return formData;
  }

  Options _multipartOptions() {
    return Options(
      contentType: Headers.multipartFormDataContentType,
      headers: {'Accept': ApiConstants.acceptJson},
    );
  }
}
