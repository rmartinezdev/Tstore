import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/cart/domain/entities/cart_item.dart';
import 'package:tstore/features/cart/domain/repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository _repository;
  GetCartUseCase(this._repository);
  Future<Either<Failure, List<CartItem>>> call({bool forceRefresh = false}) =>
      _repository.getCart(forceRefresh: forceRefresh);
}

class AddToCartUseCase {
  final CartRepository _repository;
  AddToCartUseCase(this._repository);
  Future<Either<Failure, List<CartItem>>> call(int productId, int quantity) =>
      _repository.addToCart(productId, quantity);
}

class UpdateCartItemUseCase {
  final CartRepository _repository;
  UpdateCartItemUseCase(this._repository);
  Future<Either<Failure, List<CartItem>>> call(int productId, int quantity) =>
      _repository.updateCartItem(productId, quantity);
}

class RemoveFromCartUseCase {
  final CartRepository _repository;
  RemoveFromCartUseCase(this._repository);
  Future<Either<Failure, List<CartItem>>> call(int productId) =>
      _repository.removeFromCart(productId);
}

class ClearCartUseCase {
  final CartRepository _repository;
  ClearCartUseCase(this._repository);
  Future<Either<Failure, List<CartItem>>> call() => _repository.clearCart();
}

class SyncCartUseCase {
  final CartRepository _repository;
  SyncCartUseCase(this._repository);
  Future<Either<Failure, void>> call() => _repository.syncOfflineCart();
}
