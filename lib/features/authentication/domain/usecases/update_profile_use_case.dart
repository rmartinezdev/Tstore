import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/entities/user.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, User>> call(String name, String phone, String address) {
    return _repository.updateProfile(name, phone, address);
  }
}
