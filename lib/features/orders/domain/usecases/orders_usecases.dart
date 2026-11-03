import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/orders/domain/entities/order.dart';
import 'package:tstore/features/orders/domain/repositories/orders_repository.dart';

class GetOrdersUseCase {
  final OrdersRepository _repository;
  GetOrdersUseCase(this._repository);
  Future<Either<Failure, List<Order>>> call() => _repository.getOrders();
}

class CreateOrderUseCase {
  final OrdersRepository _repository;
  CreateOrderUseCase(this._repository);
  Future<Either<Failure, Order>> call() => _repository.createOrder();
}
