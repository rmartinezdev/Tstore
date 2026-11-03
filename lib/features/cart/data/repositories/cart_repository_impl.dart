import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/core/services/connectivity_service.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:tstore/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:tstore/features/cart/data/models/cart_item_model.dart';
import 'package:tstore/features/cart/domain/entities/cart_item.dart';
import 'package:tstore/features/cart/domain/repositories/cart_repository.dart';
import 'package:tstore/features/products/data/datasources/products_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;
  final CartLocalDataSource _localDataSource;
  final ProductsLocalDataSource _productsLocalDataSource;
  final ConnectivityService _connectivityService;

  CartRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._productsLocalDataSource,
    this._connectivityService,
  );

  @override
  Future<Either<Failure, List<CartItem>>> getCart({bool forceRefresh = false}) async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        await syncOfflineCart(); // Pre-synchronize queue if any
        final serverCart = await _remoteDataSource.getCart();
        await _localDataSource.cacheCart(serverCart);
        return Either.right(serverCart);
      } on Failure catch (_) {
        final local = await _localDataSource.getCart();
        return Either.right(local);
      } catch (e) {
        final local = await _localDataSource.getCart();
        return Either.right(local);
      }
    } else {
      try {
        final local = await _localDataSource.getCart();
        return Either.right(local);
      } catch (e) {
        return Either.left(CacheFailure('Error de base local: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> addToCart(int productId, int quantity) async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        await syncOfflineCart();
        final serverCart = await _remoteDataSource.addToCart(productId, quantity);
        await _localDataSource.cacheCart(serverCart);
        return Either.right(serverCart);
      } on Failure catch (f) {
        return Either.left(f);
      } catch (e) {
        return Either.left(ServerFailure(e.toString()));
      }
    } else {
      // Offline Flow
      try {
        final product = await _productsLocalDataSource.getProductById(productId);
        if (product != null) {
          final cartItem = CartItemModel(
            productId: productId,
            quantity: quantity,
            product: product,
          );
          await _localDataSource.addToCartOffline(cartItem);
          final local = await _localDataSource.getCart();
          return Either.right(local);
        }
        return Either.left(const CacheFailure('Producto no encontrado en caché local.'));
      } catch (e) {
        return Either.left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> updateCartItem(int productId, int quantity) async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        await syncOfflineCart();
        final serverCart = await _remoteDataSource.updateCartItem(productId, quantity);
        await _localDataSource.cacheCart(serverCart);
        return Either.right(serverCart);
      } on Failure catch (f) {
        return Either.left(f);
      } catch (e) {
        return Either.left(ServerFailure(e.toString()));
      }
    } else {
      try {
        await _localDataSource.updateCartItemOffline(productId, quantity);
        final local = await _localDataSource.getCart();
        return Either.right(local);
      } catch (e) {
        return Either.left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> removeFromCart(int productId) async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        await syncOfflineCart();
        final serverCart = await _remoteDataSource.removeFromCart(productId);
        await _localDataSource.cacheCart(serverCart);
        return Either.right(serverCart);
      } on Failure catch (f) {
        return Either.left(f);
      } catch (e) {
        return Either.left(ServerFailure(e.toString()));
      }
    } else {
      try {
        await _localDataSource.removeFromCartOffline(productId);
        final local = await _localDataSource.getCart();
        return Either.right(local);
      } catch (e) {
        return Either.left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> clearCart() async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        await syncOfflineCart();
        final serverCart = await _remoteDataSource.clearCart();
        await _localDataSource.cacheCart(serverCart);
        return Either.right(serverCart);
      } on Failure catch (f) {
        return Either.left(f);
      } catch (e) {
        return Either.left(ServerFailure(e.toString()));
      }
    } else {
      try {
        await _localDataSource.clearCartOffline();
        return Either.right([]);
      } catch (e) {
        return Either.left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineCart() async {
    final pending = await _localDataSource.getPendingSyncActions();
    if (pending.isEmpty) return Either.right(null);

    try {
      for (final action in pending) {
        final act = action['action'] as String;
        final pId = action['product_id'] as int;
        final qty = action['quantity'] as int;

        if (act == 'add') {
          await _remoteDataSource.addToCart(pId, qty);
        } else if (act == 'update') {
          await _remoteDataSource.updateCartItem(pId, qty);
        } else if (act == 'remove') {
          await _remoteDataSource.removeFromCart(pId);
        } else if (act == 'clear') {
          await _remoteDataSource.clearCart();
        }
      }
      await _localDataSource.clearPendingSyncActions();
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure('Sincronización fallida: $e'));
    }
  }
}
