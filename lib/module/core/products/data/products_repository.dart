import 'package:ezhandy_user/core/network/api_client.dart';
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
}
