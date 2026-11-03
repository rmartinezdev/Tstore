import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tstore/features/products/domain/entities/product.dart';

class GetFavoritesUseCase {
  final FavoritesRepository _repository;
  GetFavoritesUseCase(this._repository);
  Future<Either<Failure, List<Product>>> call() => _repository.getFavorites();
}

class AddToFavoritesUseCase {
  final FavoritesRepository _repository;
  AddToFavoritesUseCase(this._repository);
  Future<Either<Failure, void>> call(int productId) => _repository.addToFavorites(productId);
}

class RemoveFromFavoritesUseCase {
  final FavoritesRepository _repository;
  RemoveFromFavoritesUseCase(this._repository);
  Future<Either<Failure, void>> call(int productId) => _repository.removeFromFavorites(productId);
}

class IsFavoriteUseCase {
  final FavoritesRepository _repository;
  IsFavoriteUseCase(this._repository);
  Future<bool> call(int productId) => _repository.isFavorite(productId);
}
