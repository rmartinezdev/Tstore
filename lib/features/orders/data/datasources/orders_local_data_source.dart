import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/database/hive_database.dart';
import 'package:tstore/features/orders/data/models/order_model.dart';

abstract class OrdersLocalDataSource {
  Future<void> cacheOrders(List<OrderModel> orders);
  Future<void> cacheOrder(OrderModel order);
  Future<List<OrderModel>> getOrders();
  Future<void> clearCache();
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  static const String _ordersListKey = 'orders_cache_list';

  @override
  Future<void> cacheOrders(List<OrderModel> orders) async {
    final listJson = orders.map((o) => o.toJson()).toList();
    await HiveDatabase.put(AppConstants.ordersBox, _ordersListKey, listJson);
  }

  @override
  Future<void> cacheOrder(OrderModel order) async {
    final orders = await getOrders();
    orders.removeWhere((o) => o.id == order.id);
    orders.add(order);
    await cacheOrders(orders);
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final cached = HiveDatabase.get(AppConstants.ordersBox, _ordersListKey);
    if (cached is List) {
      return cached.map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json as Map))).toList();
    }
    return [];
  }

  @override
  Future<void> clearCache() async {
    await HiveDatabase.delete(AppConstants.ordersBox, _ordersListKey);
  }
}
