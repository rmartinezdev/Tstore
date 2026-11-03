import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/database/hive_database.dart';
import 'package:tstore/features/cart/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<void> cacheCart(List<CartItemModel> items);
  Future<List<CartItemModel>> getCart();
  Future<void> addToCartOffline(CartItemModel item);
  Future<void> updateCartItemOffline(int productId, int quantity);
  Future<void> removeFromCartOffline(int productId);
  Future<void> clearCartOffline();
  
  // Offline sync queue
  Future<void> recordPendingSyncAction(int productId, int quantity, String action);
  Future<List<Map<String, dynamic>>> getPendingSyncActions();
  Future<void> clearPendingSyncActions();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _syncQueueKey = 'cart_pending_sync_queue';

  @override
  Future<void> cacheCart(List<CartItemModel> items) async {
    // Clear and put items
    final entries = HiveDatabase.getAllAsMap(AppConstants.cartBox);
    final keysToDelete = entries.keys.where((k) => k != _syncQueueKey).toList();
    for (final k in keysToDelete) {
      await HiveDatabase.delete(AppConstants.cartBox, k);
    }

    final Map<String, dynamic> newEntries = {};
    for (final item in items) {
      newEntries[item.productId.toString()] = item.toJson();
    }
    await HiveDatabase.putAll(AppConstants.cartBox, newEntries);
  }

  @override
  Future<List<CartItemModel>> getCart() async {
    final entries = HiveDatabase.getAllAsMap(AppConstants.cartBox);
    final items = <CartItemModel>[];
    for (final entry in entries.entries) {
      if (entry.key != _syncQueueKey && entry.value is Map) {
        items.add(CartItemModel.fromJson(Map<String, dynamic>.from(entry.value as Map)));
      }
    }
    return items;
  }

  @override
  Future<void> addToCartOffline(CartItemModel item) async {
    final cached = HiveDatabase.get(AppConstants.cartBox, item.productId.toString());
    if (cached != null) {
      final existing = CartItemModel.fromJson(Map<String, dynamic>.from(cached as Map));
      final updated = existing.copyWith(quantity: existing.quantity + item.quantity);
      await HiveDatabase.put(AppConstants.cartBox, item.productId.toString(), (updated as CartItemModel).toJson());
    } else {
      await HiveDatabase.put(AppConstants.cartBox, item.productId.toString(), item.toJson());
    }
    await recordPendingSyncAction(item.productId, item.quantity, 'add');
  }

  @override
  Future<void> updateCartItemOffline(int productId, int quantity) async {
    final cached = HiveDatabase.get(AppConstants.cartBox, productId.toString());
    if (cached != null) {
      final existing = CartItemModel.fromJson(Map<String, dynamic>.from(cached as Map));
      final updated = existing.copyWith(quantity: quantity);
      await HiveDatabase.put(AppConstants.cartBox, productId.toString(), (updated as CartItemModel).toJson());
    }
    await recordPendingSyncAction(productId, quantity, 'update');
  }

  @override
  Future<void> removeFromCartOffline(int productId) async {
    await HiveDatabase.delete(AppConstants.cartBox, productId.toString());
    await recordPendingSyncAction(productId, 0, 'remove');
  }

  @override
  Future<void> clearCartOffline() async {
    final entries = HiveDatabase.getAllAsMap(AppConstants.cartBox);
    final keysToDelete = entries.keys.where((k) => k != _syncQueueKey).toList();
    for (final k in keysToDelete) {
      await HiveDatabase.delete(AppConstants.cartBox, k);
    }
    await recordPendingSyncAction(0, 0, 'clear');
  }

  @override
  Future<void> recordPendingSyncAction(int productId, int quantity, String action) async {
    final queue = await getPendingSyncActions();
    
    // Optimize queue: if we delete an item, we can remove previous add/updates of the same item
    if (action == 'remove') {
      queue.removeWhere((item) => item['product_id'] == productId);
    } else if (action == 'clear') {
      queue.clear();
    }
    
    queue.add({
      'product_id': productId,
      'quantity': quantity,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await HiveDatabase.put(AppConstants.cartBox, _syncQueueKey, queue);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncActions() async {
    final raw = HiveDatabase.get(AppConstants.cartBox, _syncQueueKey);
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  @override
  Future<void> clearPendingSyncActions() async {
    await HiveDatabase.delete(AppConstants.cartBox, _syncQueueKey);
  }
}
