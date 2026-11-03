import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/entities/user.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, User>> call(String name, String email, String phone, String password) {
    return _repository.register(name, email, phone, password);
  }
}
