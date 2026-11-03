import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/network/api_client.dart';
import 'package:tstore/features/products/data/models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    int limit = 10,
    int offset = 0,
    int? categoryId,
    String? search,
    String? sortBy,
  });

  Future<ProductModel> getProductById(int id);
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getNewProducts();
  Future<List<ProductModel>> getOfferProducts();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient _apiClient;

  ProductsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductModel>> getProducts({
    int limit = 10,
    int offset = 0,
    int? categoryId,
    String? search,
    String? sortBy,
  }) async {
    final queryParams = {
      'limit': limit,
      'offset': offset,
      if (categoryId != null) 'category_id': categoryId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
    };

    final response = await _apiClient.get(AppConstants.productsEndpoint, queryParameters: queryParams);
    final List data = response.data['products'] as List;
    return data.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await _apiClient.get('${AppConstants.productsEndpoint}/$id');
    return ProductModel.fromJson(response.data['product'] as Map<String, dynamic>);
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final response = await _apiClient.get(AppConstants.productsEndpoint, queryParameters: {'is_featured': true});
    final List data = response.data['products'] as List;
    return data.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ProductModel>> getNewProducts() async {
    final response = await _apiClient.get(AppConstants.productsEndpoint, queryParameters: {'is_new': true});
    final List data = response.data['products'] as List;
    return data.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ProductModel>> getOfferProducts() async {
    final response = await _apiClient.get(AppConstants.productsEndpoint, queryParameters: {'is_offer': true});
    final List data = response.data['products'] as List;
    return data.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
