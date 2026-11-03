import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tstore/core/config/dependency_injection.dart';
import 'package:tstore/features/orders/domain/entities/order.dart';
import 'package:tstore/features/orders/domain/usecases/orders_usecases.dart';

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final bool isCheckoutSuccess;
  final String? errorMessage;

  const OrdersState({
    required this.orders,
    required this.isLoading,
    required this.isCheckoutSuccess,
    this.errorMessage,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isCheckoutSuccess,
    String? errorMessage,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isCheckoutSuccess: isCheckoutSuccess ?? this.isCheckoutSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final GetOrdersUseCase _getOrdersUseCase;
  final CreateOrderUseCase _createOrderUseCase;

  OrdersNotifier({
    required GetOrdersUseCase getOrdersUseCase,
    required CreateOrderUseCase createOrderUseCase,
  })  : _getOrdersUseCase = getOrdersUseCase,
        _createOrderUseCase = createOrderUseCase,
        super(const OrdersState(orders: [], isLoading: false, isCheckoutSuccess: false)) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getOrdersUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (orders) => state = state.copyWith(orders: orders, isLoading: false),
    );
  }

  Future<bool> checkout() async {
    state = state.copyWith(isLoading: true, isCheckoutSuccess: false, errorMessage: null);
    final result = await _createOrderUseCase();
    
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (newOrder) {
        state = state.copyWith(
          orders: [newOrder, ...state.orders],
          isLoading: false,
          isCheckoutSuccess: true,
        );
        return true;
      },
    );
  }

  void resetCheckoutStatus() {
    state = state.copyWith(isCheckoutSuccess: false, errorMessage: null);
  }
}

// Global Orders Provider definition
final ordersNotifierProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(
    getOrdersUseCase: sl<GetOrdersUseCase>(),
    createOrderUseCase: sl<CreateOrderUseCase>(),
  );
});
