import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/database/hive_database.dart';
import 'package:tstore/features/categories/data/models/category_model.dart';

abstract class CategoriesLocalDataSource {
  Future<void> cacheCategoriesTree(List<CategoryModel> categories);
  Future<List<CategoryModel>> getCategoriesTree();
  Future<void> clearCache();
}

class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  static const _categoriesTreeKey = 'categories_tree_cache';

  @override
  Future<void> cacheCategoriesTree(List<CategoryModel> categories) async {
    final listJson = categories.map((cat) => cat.toJson()).toList();
    await HiveDatabase.put(AppConstants.categoriesBox, _categoriesTreeKey, listJson);
  }

  @override
  Future<List<CategoryModel>> getCategoriesTree() async {
    final cached = HiveDatabase.get(AppConstants.categoriesBox, _categoriesTreeKey);
    if (cached != null && cached is List) {
      return cached.map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json as Map))).toList();
    }
    return [];
  }

  @override
  Future<void> clearCache() async {
    await HiveDatabase.delete(AppConstants.categoriesBox, _categoriesTreeKey);
  }
}
