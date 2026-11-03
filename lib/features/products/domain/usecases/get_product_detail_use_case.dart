import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/products/domain/entities/product.dart';
import 'package:tstore/features/products/domain/repositories/products_repository.dart';

class GetProductDetailUseCase {
  final ProductsRepository _repository;

  GetProductDetailUseCase(this._repository);

  Future<Either<Failure, Product>> call(int id) {
    return _repository.getProductById(id);
  }
}
