import 'package:tstore/features/products/domain/entities/product.dart';

class CartItem {
  final int productId;
  final int quantity;
  final Product product;

  const CartItem({
    required this.productId,
    required this.quantity,
    required this.product,
  });

  double get subtotal => product.priceOffer * quantity;

  CartItem copyWith({int? quantity, Product? product}) {
    return CartItem(
      productId: productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }
}
