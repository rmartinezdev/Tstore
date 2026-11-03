import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/core/services/connectivity_service.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/categories/data/datasources/categories_local_data_source.dart';
import 'package:tstore/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:tstore/features/categories/domain/entities/category.dart';
import 'package:tstore/features/categories/domain/repositories/categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource _remoteDataSource;
  final CategoriesLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  CategoriesRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivityService,
  );

  @override
  Future<Either<Failure, List<Category>>> getCategoriesTree({bool forceRefresh = false}) async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      if (forceRefresh) {
        return _fetchAndCacheRemote();
      }

      // Check if cache exists
      try {
        final cached = await _localDataSource.getCategoriesTree();
        if (cached.isNotEmpty) {
          return Either.right(cached);
        }
      } catch (_) {}

      return _fetchAndCacheRemote();
    } else {
      // Offline mode
      try {
        final cached = await _localDataSource.getCategoriesTree();
        if (cached.isNotEmpty) {
          return Either.right(cached);
        }
        return Either.left(const NetworkFailure('Sin conexión a internet y sin caché local.'));
      } catch (e) {
        return Either.left(CacheFailure('Error al leer caché de categorías: $e'));
      }
    }
  }

  Future<Either<Failure, List<Category>>> _fetchAndCacheRemote() async {
    try {
      final remoteData = await _remoteDataSource.getCategoriesTree();
      await _localDataSource.cacheCategoriesTree(remoteData);
      return Either.right(remoteData);
    } on Failure catch (f) {
      return Either.left(f);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }
}
