import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/network/api_client.dart';
import 'package:tstore/features/cart/data/models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCart();
  Future<List<CartItemModel>> addToCart(int productId, int quantity);
  Future<List<CartItemModel>> updateCartItem(int productId, int quantity);
  Future<List<CartItemModel>> removeFromCart(int productId);
  Future<List<CartItemModel>> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _apiClient;

  CartRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CartItemModel>> getCart() async {
    final response = await _apiClient.get(AppConstants.cartEndpoint);
    final List data = response.data['cart'] as List;
    return data.map((json) => CartItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CartItemModel>> addToCart(int productId, int quantity) async {
    final response = await _apiClient.post('${AppConstants.cartEndpoint}/add', data: {
      'product_id': productId,
      'quantity': quantity,
    });
    final List data = response.data['cart'] as List;
    return data.map((json) => CartItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CartItemModel>> updateCartItem(int productId, int quantity) async {
    final response = await _apiClient.put('${AppConstants.cartEndpoint}/update', data: {
      'product_id': productId,
      'quantity': quantity,
    });
    final List data = response.data['cart'] as List;
    return data.map((json) => CartItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CartItemModel>> removeFromCart(int productId) async {
    final response = await _apiClient.delete('${AppConstants.cartEndpoint}/remove', data: {
      'product_id': productId,
    });
    final List data = response.data['cart'] as List;
    return data.map((json) => CartItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CartItemModel>> clearCart() async {
    final response = await _apiClient.delete('${AppConstants.cartEndpoint}/clear');
    final List data = response.data['cart'] as List;
    return data.map((json) => CartItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
