import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/core/services/connectivity_service.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:tstore/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:tstore/features/orders/domain/entities/order.dart';
import 'package:tstore/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;
  final OrdersLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  OrdersRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivityService,
  );

  @override
  Future<Either<Failure, List<Order>>> getOrders() async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        final remote = await _remoteDataSource.getOrders();
        await _localDataSource.cacheOrders(remote);
        return Either.right(remote);
      } catch (_) {
        final local = await _localDataSource.getOrders();
        return Either.right(local);
      }
    } else {
      try {
        final local = await _localDataSource.getOrders();
        return Either.right(local);
      } catch (e) {
        return Either.left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Order>> createOrder() async {
    final isOnline = await _connectivityService.isConnected;

    if (isOnline) {
      try {
        final order = await _remoteDataSource.createOrder();
        await _localDataSource.cacheOrder(order);
        return Either.right(order);
      } on Failure catch (f) {
        return Either.left(f);
      } catch (e) {
        return Either.left(ServerFailure(e.toString()));
      }
    } else {
      return Either.left(const NetworkFailure('No se pueden finalizar compras sin conexión a internet.'));
    }
  }
}
