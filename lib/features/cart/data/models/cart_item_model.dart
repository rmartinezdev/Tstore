import 'package:tstore/features/cart/domain/entities/cart_item.dart';
import 'package:tstore/features/products/data/models/product_model.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.productId,
    required super.quantity,
    required super.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int? ?? 1,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'product': (product as ProductModel).toJson(),
    };
  }
}
