import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> register(String name, String email, String phone, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile(String name, String phone, String address);
}

// Minimalist Either class implementation for functional error handling without adding fpdart package
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool isLeft;

  const Either._(this._left, this._right, this.isLeft);

  factory Either.left(L left) => Either._(left, null, true);
  factory Either.right(R right) => Either._(null, right, false);

  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight) {
    if (isLeft) {
      return onLeft(_left as L);
    } else {
      return onRight(_right as R);
    }
  }
}
