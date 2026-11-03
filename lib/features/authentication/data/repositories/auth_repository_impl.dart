import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:tstore/features/authentication/domain/entities/user.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final user = await _remoteDataSource.login(username, password);
      return Either.right(user);
    } on Failure catch (f) {
      return Either.left(f);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(
      String name, String email, String phone, String password) async {
    try {
      final user = await _remoteDataSource.register(name, email, phone, password);
      return Either.right(user);
    } on Failure catch (f) {
      return Either.left(f);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return Either.right(null);
    } on Failure catch (f) {
      return Either.left(f);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final user = await _remoteDataSource.getProfile();
      return Either.right(user);
    } on Failure catch (f) {
      return Either.left(f);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(
      String name, String phone, String address) async {
    try {
      final user = await _remoteDataSource.updateProfile(name, phone, address);
      return Either.right(user);
    } on Failure catch (f) {
      return Either.left(f);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }
}
