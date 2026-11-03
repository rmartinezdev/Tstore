import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCart({bool forceRefresh = false});
  Future<Either<Failure, List<CartItem>>> addToCart(int productId, int quantity);
  Future<Either<Failure, List<CartItem>>> updateCartItem(int productId, int quantity);
  Future<Either<Failure, List<CartItem>>> removeFromCart(int productId);
  Future<Either<Failure, List<CartItem>>> clearCart();
  Future<Either<Failure, void>> syncOfflineCart();
}
