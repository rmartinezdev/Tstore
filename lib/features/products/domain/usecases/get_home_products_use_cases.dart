import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/products/domain/entities/product.dart';
import 'package:tstore/features/products/domain/repositories/products_repository.dart';

class GetFeaturedProductsUseCase {
  final ProductsRepository _repository;
  GetFeaturedProductsUseCase(this._repository);
  Future<Either<Failure, List<Product>>> call() => _repository.getFeaturedProducts();
}

class GetNewProductsUseCase {
  final ProductsRepository _repository;
  GetNewProductsUseCase(this._repository);
  Future<Either<Failure, List<Product>>> call() => _repository.getNewProducts();
}

class GetOfferProductsUseCase {
  final ProductsRepository _repository;
  GetOfferProductsUseCase(this._repository);
  Future<Either<Failure, List<Product>>> call() => _repository.getOfferProducts();
}
