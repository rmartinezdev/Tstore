import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/products/domain/entities/product.dart';

abstract class ProductsRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    int limit = 10,
    int offset = 0,
    int? categoryId,
    String? search,
    String? sortBy,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Product>> getProductById(int id);
  Future<Either<Failure, List<Product>>> getFeaturedProducts();
  Future<Either<Failure, List<Product>>> getNewProducts();
  Future<Either<Failure, List<Product>>> getOfferProducts();
}
