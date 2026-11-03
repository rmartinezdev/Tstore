import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/database/hive_database.dart';

abstract class FavoritesLocalDataSource {
  Future<void> cacheFavorites(List<int> productIds);
  Future<List<int>> getFavoritesIds();
  Future<void> addToFavoritesOffline(int productId);
  Future<void> removeFromFavoritesOffline(int productId);
  
  // Pending actions sync queue
  Future<void> recordPendingAction(int productId, String action);
  Future<List<Map<String, dynamic>>> getPendingActions();
  Future<void> clearPendingActions();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  static const String _favoritesListKey = 'favorites_ids_list';
  static const String _syncQueueKey = 'favorites_pending_sync_queue';

  @override
  Future<void> cacheFavorites(List<int> productIds) async {
    await HiveDatabase.put(AppConstants.favoritesBox, _favoritesListKey, productIds);
  }

  @override
  Future<List<int>> getFavoritesIds() async {
    final cached = HiveDatabase.get(AppConstants.favoritesBox, _favoritesListKey);
    if (cached is List) {
      return cached.cast<int>();
    }
    return [];
  }

  @override
  Future<void> addToFavoritesOffline(int productId) async {
    final current = await getFavoritesIds();
    if (!current.contains(productId)) {
      current.add(productId);
      await cacheFavorites(current);
    }
    await recordPendingAction(productId, 'add');
  }

  @override
  Future<void> removeFromFavoritesOffline(int productId) async {
    final current = await getFavoritesIds();
    if (current.remove(productId)) {
      await cacheFavorites(current);
    }
    await recordPendingAction(productId, 'remove');
  }

  @override
  Future<void> recordPendingAction(int productId, String action) async {
    final queue = await getPendingActions();
    
    // Optimize: if same product is added and removed, we can cancel both out
    queue.removeWhere((item) => item['product_id'] == productId);
    queue.add({
      'product_id': productId,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    await HiveDatabase.put(AppConstants.favoritesBox, _syncQueueKey, queue);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingActions() async {
    final raw = HiveDatabase.get(AppConstants.favoritesBox, _syncQueueKey);
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  @override
  Future<void> clearPendingActions() async {
    await HiveDatabase.delete(AppConstants.favoritesBox, _syncQueueKey);
  }
}
