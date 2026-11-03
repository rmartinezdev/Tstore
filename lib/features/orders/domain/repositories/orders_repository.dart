import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/orders/domain/entities/order.dart';

abstract class OrdersRepository {
  Future<Either<Failure, List<Order>>> getOrders();
  Future<Either<Failure, Order>> createOrder();
}
