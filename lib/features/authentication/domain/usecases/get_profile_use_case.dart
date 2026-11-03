import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/entities/user.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';

class GetProfileUseCase {
  final AuthRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, User>> call() {
    return _repository.getProfile();
  }
}
