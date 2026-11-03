import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/products/domain/entities/product.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<Product>>> getFavorites();
  Future<Either<Failure, void>> addToFavorites(int productId);
  Future<Either<Failure, void>> removeFromFavorites(int productId);
  Future<Either<Failure, void>> syncOfflineFavorites();
  Future<bool> isFavorite(int productId);
}
