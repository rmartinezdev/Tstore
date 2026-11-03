import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/network/api_client.dart';
import 'package:tstore/features/products/data/models/product_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<ProductModel>> getFavorites();
  Future<void> addToFavorites(int productId);
  Future<void> removeFromFavorites(int productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final ApiClient _apiClient;

  FavoritesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductModel>> getFavorites() async {
    final response = await _apiClient.get(AppConstants.favoritesEndpoint);
    final List data = response.data['favorites'] as List;
    return data.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addToFavorites(int productId) async {
    await _apiClient.post('${AppConstants.favoritesEndpoint}/add', data: {
      'product_id': productId,
    });
  }

  @override
  Future<void> removeFromFavorites(int productId) async {
    await _apiClient.delete('${AppConstants.favoritesEndpoint}/remove', data: {
      'product_id': productId,
    });
  }
}
