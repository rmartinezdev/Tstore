import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/products/domain/entities/product.dart';
import 'package:tstore/features/products/domain/repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository _repository;

  GetProductsUseCase(this._repository);

  Future<Either<Failure, List<Product>>> call({
    int limit = 10,
    int offset = 0,
    int? categoryId,
    String? search,
    String? sortBy,
    bool forceRefresh = false,
  }) {
    return _repository.getProducts(
      limit: limit,
      offset: offset,
      categoryId: categoryId,
      search: search,
      sortBy: sortBy,
      forceRefresh: forceRefresh,
    );
  }
}
