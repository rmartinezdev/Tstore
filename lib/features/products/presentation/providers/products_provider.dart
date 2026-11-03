import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tstore/core/config/dependency_injection.dart';
import 'package:tstore/features/products/domain/entities/product.dart';
import 'package:tstore/features/products/domain/usecases/get_products_use_case.dart';
import 'package:tstore/features/products/domain/usecases/get_product_detail_use_case.dart';
import 'package:tstore/features/products/domain/usecases/get_home_products_use_cases.dart';

class ProductsListState {
  final List<Product> products;
  final bool isLoading;
  final bool isEndReached;
  final int offset;
  final int? categoryId;
  final String search;
  final String sortBy;
  final String? errorMessage;

  const ProductsListState({
    required this.products,
    required this.isLoading,
    required this.isEndReached,
    required this.offset,
    this.categoryId,
    required this.search,
    required this.sortBy,
    this.errorMessage,
  });

  ProductsListState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isEndReached,
    int? offset,
    int? Function()? categoryId,
    String? search,
    String? sortBy,
    String? Function()? errorMessage,
  }) {
    return ProductsListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isEndReached: isEndReached ?? this.isEndReached,
      offset: offset ?? this.offset,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsListState> {
  final GetProductsUseCase _getProductsUseCase;
  static const int _limit = 10;

  ProductsNotifier(this._getProductsUseCase)
      : super(const ProductsListState(
          products: [],
          isLoading: false,
          isEndReached: false,
          offset: 0,
          search: '',
          sortBy: 'name',
        )) {
    loadNextPage();
  }

  Future<void> loadNextPage({bool forceRefresh = false}) async {
    if (state.isLoading || (state.isEndReached && !forceRefresh)) return;

    state = state.copyWith(isLoading: true, errorMessage: () => null);

    final currentOffset = forceRefresh ? 0 : state.offset;

    final result = await _getProductsUseCase(
      limit: _limit,
      offset: currentOffset,
      categoryId: state.categoryId,
      search: state.search,
      sortBy: state.sortBy,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        );
      },
      (newProducts) {
        final allProducts = forceRefresh ? newProducts : [...state.products, ...newProducts];
        state = state.copyWith(
          products: allProducts,
          isLoading: false,
          isEndReached: newProducts.length < _limit,
          offset: currentOffset + newProducts.length,
        );
      },
    );
  }

  void updateFilters({int? categoryId, String? search, String? sortBy}) {
    state = state.copyWith(
      products: [],
      offset: 0,
      isEndReached: false,
      categoryId: categoryId != null ? () => categoryId : () => null,
      search: search ?? state.search,
      sortBy: sortBy ?? state.sortBy,
    );
    loadNextPage(forceRefresh: true);
  }

  void clearFilters() {
    state = const ProductsListState(
      products: [],
      isLoading: false,
      isEndReached: false,
      offset: 0,
      search: '',
      sortBy: 'name',
    );
    loadNextPage(forceRefresh: true);
  }
}

// Global Products Provider (supporting infinite scrolling, filters, searching)
final productsNotifierProvider =
    StateNotifierProvider<ProductsNotifier, ProductsListState>((ref) {
  return ProductsNotifier(sl<GetProductsUseCase>());
});

// Home Feature Carousels Providers
final featuredProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final useCase = sl<GetFeaturedProductsUseCase>();
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

final newProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final useCase = sl<GetNewProductsUseCase>();
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

final offerProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final useCase = sl<GetOfferProductsUseCase>();
  final result = await useCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

// Product Details Provider (Family Provider)
final productDetailProvider =
    FutureProvider.family.autoDispose<Product, int>((ref, id) async {
  final useCase = sl<GetProductDetailUseCase>();
  final result = await useCase(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
});
