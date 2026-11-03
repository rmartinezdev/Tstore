import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tstore/core/config/dependency_injection.dart';
import 'package:tstore/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:tstore/features/products/domain/entities/product.dart';

class FavoritesNotifier extends StateNotifier<List<Product>> {
  final GetFavoritesUseCase _getFavoritesUseCase;
  final AddToFavoritesUseCase _addToFavoritesUseCase;
  final RemoveFromFavoritesUseCase _removeFromFavoritesUseCase;

  FavoritesNotifier({
    required GetFavoritesUseCase getFavoritesUseCase,
    required AddToFavoritesUseCase addToFavoritesUseCase,
    required RemoveFromFavoritesUseCase removeFromFavoritesUseCase,
  })  : _getFavoritesUseCase = getFavoritesUseCase,
        _addToFavoritesUseCase = addToFavoritesUseCase,
        _removeFromFavoritesUseCase = removeFromFavoritesUseCase,
        super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final result = await _getFavoritesUseCase();
    result.fold(
      (failure) => {}, // Suppress failure, default to empty list
      (favorites) => state = favorites,
    );
  }

  Future<void> toggleFavorite(Product product) async {
    final currentlyFav = state.any((p) => p.id == product.id);

    if (currentlyFav) {
      // Optimistic UI updates
      state = state.where((p) => p.id != product.id).toList();
      final result = await _removeFromFavoritesUseCase(product.id);
      result.fold(
        (failure) {
          // Revert if failed
          state = [...state, product];
        },
        (_) {},
      );
    } else {
      // Optimistic UI updates
      state = [...state, product];
      final result = await _addToFavoritesUseCase(product.id);
      result.fold(
        (failure) {
          // Revert if failed
          state = state.where((p) => p.id != product.id).toList();
        },
        (_) {},
      );
    }
  }

  bool isProductFavorite(int productId) {
    return state.any((p) => p.id == productId);
  }
}

// Global Favorites provider definition
final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, List<Product>>((ref) {
  return FavoritesNotifier(
    getFavoritesUseCase: sl<GetFavoritesUseCase>(),
    addToFavoritesUseCase: sl<AddToFavoritesUseCase>(),
    removeFromFavoritesUseCase: sl<RemoveFromFavoritesUseCase>(),
  );
});
