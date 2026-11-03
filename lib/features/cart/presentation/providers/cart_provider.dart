import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tstore/core/config/dependency_injection.dart';
import 'package:tstore/features/cart/domain/entities/cart_item.dart';
import 'package:tstore/features/cart/domain/usecases/cart_usecases.dart';
import 'package:tstore/features/products/domain/entities/product.dart';

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? errorMessage;

  const CartState({
    required this.items,
    required this.isLoading,
    this.errorMessage,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartItemUseCase _updateCartItemUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final SyncCartUseCase _syncCartUseCase;

  CartNotifier({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required UpdateCartItemUseCase updateCartItemUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required ClearCartUseCase clearCartUseCase,
    required SyncCartUseCase syncCartUseCase,
  })  : _getCartUseCase = getCartUseCase,
        _addToCartUseCase = addToCartUseCase,
        _updateCartItemUseCase = updateCartItemUseCase,
        _removeFromCartUseCase = removeFromCartUseCase,
        _clearCartUseCase = clearCartUseCase,
        _syncCartUseCase = syncCartUseCase,
        super(const CartState(items: [], isLoading: false)) {
    loadCart();
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true);
    final result = await _getCartUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (items) => state = CartState(items: items, isLoading: false),
    );
  }

  Future<void> addToCart(Product product, int quantity) async {
    state = state.copyWith(isLoading: true);
    final result = await _addToCartUseCase(product.id, quantity);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (items) => state = CartState(items: items, isLoading: false),
    );
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    state = state.copyWith(isLoading: true);
    final result = await _updateCartItemUseCase(productId, quantity);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (items) => state = CartState(items: items, isLoading: false),
    );
  }

  Future<void> removeFromCart(int productId) async {
    state = state.copyWith(isLoading: true);
    final result = await _removeFromCartUseCase(productId);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (items) => state = CartState(items: items, isLoading: false),
    );
  }

  Future<void> clearCart() async {
    state = state.copyWith(isLoading: true);
    final result = await _clearCartUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (items) => state = CartState(items: items, isLoading: false),
    );
  }

  Future<void> syncCartOffline() async {
    state = state.copyWith(isLoading: true);
    final result = await _syncCartUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) {
        loadCart();
      },
    );
  }
}

// Global Cart Provider definition
final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(
    getCartUseCase: sl<GetCartUseCase>(),
    addToCartUseCase: sl<AddToCartUseCase>(),
    updateCartItemUseCase: sl<UpdateCartItemUseCase>(),
    removeFromCartUseCase: sl<RemoveFromCartUseCase>(),
    clearCartUseCase: sl<ClearCartUseCase>(),
    syncCartUseCase: sl<SyncCartUseCase>(),
  );
});
