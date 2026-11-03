import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/core/services/connectivity_service.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:tstore/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:tstore/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tstore/features/products/data/datasources/products_local_data_source.dart';
import 'package:tstore/features/products/domain/entities/product.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;
  final FavoritesLocalDataSource _localDataSource;
  final ProductsLocalDataSource _productsLocalDataSource;
  final ConnectivityService _connectivityService;

  FavoritesRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._productsLocalDataSource,
    this._connectivityService,
  );

  @override
  Future<Either<Failure, List<Product>>> getFavorites() async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        await syncOfflineFavorites();
        final remote = await _remoteDataSource.getFavorites();
        final ids = remote.map((p) => p.id).toList();
        await _localDataSource.cacheFavorites(ids);
        return Either.right(remote);
      } catch (_) {
        return _getLocalFavoritesData();
      }
    } else {
      return _getLocalFavoritesData();
    }
  }

  Future<Either<Failure, List<Product>>> _getLocalFavoritesData() async {
    try {
      final ids = await _localDataSource.getFavoritesIds();
      final products = <Product>[];
      for (final id in ids) {
        final p = await _productsLocalDataSource.getProductById(id);
        if (p != null) {
          products.add(p);
        }
      }
      return Either.right(products);
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(int productId) async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        await syncOfflineFavorites();
        await _remoteDataSource.addToFavorites(productId);
        final current = await _localDataSource.getFavoritesIds();
        if (!current.contains(productId)) {
          current.add(productId);
          await _localDataSource.cacheFavorites(current);
        }
        return Either.right(null);
      } on Failure catch (f) {
        return Either.left(f);
      } catch (e) {
        return Either.left(ServerFailure(e.toString()));
      }
    } else {
      try {
        await _localDataSource.addToFavoritesOffline(productId);
        return Either.right(null);
      } catch (e) {
        return Either.left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(int productId) async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        await syncOfflineFavorites();
        await _remoteDataSource.removeFromFavorites(productId);
        final current = await _localDataSource.getFavoritesIds();
        current.remove(productId);
        await _localDataSource.cacheFavorites(current);
        return Either.right(null);
      } on Failure catch (f) {
        return Either.left(f);
      } catch (e) {
        return Either.left(ServerFailure(e.toString()));
      }
    } else {
      try {
        await _localDataSource.removeFromFavoritesOffline(productId);
        return Either.right(null);
      } catch (e) {
        return Either.left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineFavorites() async {
    final pending = await _localDataSource.getPendingActions();
    if (pending.isEmpty) return Either.right(null);

    try {
      for (final action in pending) {
        final act = action['action'] as String;
        final pId = action['product_id'] as int;

        if (act == 'add') {
          await _remoteDataSource.addToFavorites(pId);
        } else if (act == 'remove') {
          await _remoteDataSource.removeFromFavorites(pId);
        }
      }
      await _localDataSource.clearPendingActions();
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure('Error sincronizando favoritos: $e'));
    }
  }

  @override
  Future<bool> isFavorite(int productId) async {
    final ids = await _localDataSource.getFavoritesIds();
    return ids.contains(productId);
  }
}
