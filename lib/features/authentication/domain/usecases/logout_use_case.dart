import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}
