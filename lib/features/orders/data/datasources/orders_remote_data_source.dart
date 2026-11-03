import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/network/api_client.dart';
import 'package:tstore/features/orders/data/models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> createOrder();
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient _apiClient;

  OrdersRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _apiClient.get(AppConstants.ordersEndpoint);
    final List data = response.data['orders'] as List;
    return data.map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<OrderModel> createOrder() async {
    final response = await _apiClient.post('${AppConstants.ordersEndpoint}/create');
    return OrderModel.fromJson(response.data['order'] as Map<String, dynamic>);
  }
}
