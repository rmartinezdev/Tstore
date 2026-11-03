import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tstore/core/config/dependency_injection.dart';
import 'package:tstore/features/categories/domain/entities/category.dart';
import 'package:tstore/features/categories/domain/usecases/get_categories_tree_use_case.dart';

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final GetCategoriesTreeUseCase _getCategoriesTreeUseCase;

  CategoriesNotifier(this._getCategoriesTreeUseCase)
      : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  Future<void> fetchCategories({bool forceRefresh = false}) async {
    if (forceRefresh) {
      state = const AsyncValue.loading();
    }
    
    final result = await _getCategoriesTreeUseCase(forceRefresh: forceRefresh);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (categories) => state = AsyncValue.data(categories),
    );
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  return CategoriesNotifier(sl<GetCategoriesTreeUseCase>());
});
