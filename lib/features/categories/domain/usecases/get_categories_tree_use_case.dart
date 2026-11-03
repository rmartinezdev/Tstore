import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/categories/domain/entities/category.dart';
import 'package:tstore/features/categories/domain/repositories/categories_repository.dart';

class GetCategoriesTreeUseCase {
  final CategoriesRepository _repository;

  GetCategoriesTreeUseCase(this._repository);

  Future<Either<Failure, List<Category>>> call({bool forceRefresh = false}) {
    return _repository.getCategoriesTree(forceRefresh: forceRefresh);
  }
}
