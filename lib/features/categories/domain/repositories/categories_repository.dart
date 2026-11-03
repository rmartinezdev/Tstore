import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/categories/domain/entities/category.dart';

abstract class CategoriesRepository {
  Future<Either<Failure, List<Category>>> getCategoriesTree({bool forceRefresh = false});
}
