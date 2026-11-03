import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/entities/user.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, User>> call(String username, String password) {
    return _repository.login(username, password);
  }
}
