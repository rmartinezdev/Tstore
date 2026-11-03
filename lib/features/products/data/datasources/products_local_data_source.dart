import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/database/hive_database.dart';
import 'package:tstore/features/products/data/models/product_model.dart';

abstract class ProductsLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> cacheProduct(ProductModel product);
  Future<List<ProductModel>> getProducts({
    int limit = 10,
    int offset = 0,
    int? categoryId,
    String? search,
    String? sortBy,
  });
  Future<ProductModel?> getProductById(int id);
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getNewProducts();
  Future<List<ProductModel>> getOfferProducts();
  Future<void> clearCache();
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  
  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final Map<String, dynamic> entries = {};
    for (final p in products) {
      entries[p.id.toString()] = p.toJson();
    }
    await HiveDatabase.putAll(AppConstants.productsBox, entries);
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    await HiveDatabase.put(AppConstants.productsBox, product.id.toString(), product.toJson());
  }

  @override
  Future<List<ProductModel>> getProducts({
    int limit = 10,
    int offset = 0,
    int? categoryId,
    String? search,
    String? sortBy,
  }) async {
    final allValues = HiveDatabase.getAll(AppConstants.productsBox);
    var list = allValues
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    // Filters
    if (categoryId != null) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }

    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.sku.toLowerCase().contains(query) ||
            p.brand.toLowerCase().contains(query);
      }).toList();
    }

    // Sorting
    if (sortBy == 'price_asc') {
      list.sort((a, b) => a.priceOffer.compareTo(b.priceOffer));
    } else if (sortBy == 'price_desc') {
      list.sort((a, b) => b.priceOffer.compareTo(a.priceOffer));
    } else if (sortBy == 'name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    // Pagination
    return list.skip(offset).take(limit).toList();
  }

  @override
  Future<ProductModel?> getProductById(int id) async {
    final cached = HiveDatabase.get(AppConstants.productsBox, id.toString());
    if (cached != null) {
      return ProductModel.fromJson(Map<String, dynamic>.from(cached as Map));
    }
    return null;
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final allValues = HiveDatabase.getAll(AppConstants.productsBox);
    return allValues
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((p) => p.isFeatured)
        .toList();
  }

  @override
  Future<List<ProductModel>> getNewProducts() async {
    final allValues = HiveDatabase.getAll(AppConstants.productsBox);
    return allValues
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((p) => p.isNew)
        .toList();
  }

  @override
  Future<List<ProductModel>> getOfferProducts() async {
    final allValues = HiveDatabase.getAll(AppConstants.productsBox);
    return allValues
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((p) => p.isOffer)
        .toList();
  }

  @override
  Future<void> clearCache() async {
    await HiveDatabase.clear(AppConstants.productsBox);
  }
}
