import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/core/services/connectivity_service.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/products/data/datasources/products_local_data_source.dart';
import 'package:tstore/features/products/data/datasources/products_remote_data_source.dart';
import 'package:tstore/features/products/data/models/product_model.dart';
import 'package:tstore/features/products/domain/entities/product.dart';
import 'package:tstore/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;
  final ProductsLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  ProductsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivityService,
  );

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    int limit = 10,
    int offset = 0,
    int? categoryId,
    String? search,
    String? sortBy,
    bool forceRefresh = false,
  }) async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        if (!forceRefresh) {
          final cached = await _localDataSource.getProducts(
            limit: limit,
            offset: offset,
            categoryId: categoryId,
            search: search,
            sortBy: sortBy,
          );
          if (cached.isNotEmpty) {
            return Either.right(cached);
          }
        }

        final remoteData = await _remoteDataSource.getProducts(
          limit: limit,
          offset: offset,
          categoryId: categoryId,
          search: search,
          sortBy: sortBy,
        );
        await _localDataSource.cacheProducts(remoteData);
        return Either.right(remoteData);
      } on Failure catch (f) {
        return Either.left(f);
      } catch (e) {
        return Either.left(ServerFailure(e.toString()));
      }
    } else {
      // Offline mode
      try {
        final cached = await _localDataSource.getProducts(
          limit: limit,
          offset: offset,
          categoryId: categoryId,
          search: search,
          sortBy: sortBy,
        );
        return Either.right(cached);
      } catch (e) {
        return Either.left(CacheFailure('Error al leer caché local de productos: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(int id) async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        final remoteProduct = await _remoteDataSource.getProductById(id);
        await _localDataSource.cacheProduct(remoteProduct);
        return Either.right(remoteProduct);
      } on Failure catch (f) {
        // Fallback to local on remote fail
        final local = await _localDataSource.getProductById(id);
        if (local != null) return Either.right(local);
        return Either.left(f);
      } catch (e) {
        final local = await _localDataSource.getProductById(id);
        if (local != null) return Either.right(local);
        return Either.left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final local = await _localDataSource.getProductById(id);
        if (local != null) return Either.right(local);
        return Either.left(const NetworkFailure('Producto no disponible sin conexión.'));
      } catch (e) {
        return Either.left(CacheFailure('Error de lectura de caché: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getFeaturedProducts() async {
    return _getQueryProducts(
      onlineQuery: () => _remoteDataSource.getFeaturedProducts(),
      localQuery: () => _localDataSource.getFeaturedProducts(),
    );
  }

  @override
  Future<Either<Failure, List<Product>>> getNewProducts() async {
    return _getQueryProducts(
      onlineQuery: () => _remoteDataSource.getNewProducts(),
      localQuery: () => _localDataSource.getNewProducts(),
    );
  }

  @override
  Future<Either<Failure, List<Product>>> getOfferProducts() async {
    return _getQueryProducts(
      onlineQuery: () => _remoteDataSource.getOfferProducts(),
      localQuery: () => _localDataSource.getOfferProducts(),
    );
  }

  Future<Either<Failure, List<Product>>> _getQueryProducts({
    required Future<List<ProductModel>> Function() onlineQuery,
    required Future<List<ProductModel>> Function() localQuery,
  }) async {
    final isOnline = await _connectivityService.isConnected;
    if (isOnline) {
      try {
        final list = await onlineQuery();
        await _localDataSource.cacheProducts(list);
        return Either.right(list);
      } catch (_) {
        final local = await localQuery();
        return Either.right(local);
      }
    } else {
      final local = await localQuery();
      return Either.right(local);
    }
  }
}
