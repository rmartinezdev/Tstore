import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tstore/core/config/dependency_injection.dart';
import 'package:tstore/features/authentication/domain/entities/user.dart';
import 'package:tstore/features/authentication/domain/usecases/login_use_case.dart';
import 'package:tstore/features/authentication/domain/usecases/register_use_case.dart';
import 'package:tstore/features/authentication/domain/usecases/logout_use_case.dart';
import 'package:tstore/features/authentication/domain/usecases/get_profile_use_case.dart';
import 'package:tstore/features/authentication/domain/usecases/update_profile_use_case.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const AuthInitial()) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = const AuthLoading();
    final result = await _getProfileUseCase();
    result.fold(
      (failure) => state = const Unauthenticated(),
      (user) => state = Authenticated(user),
    );
  }

  Future<void> login(String username, String password) async {
    state = const AuthLoading();
    final result = await _loginUseCase(username, password);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = Authenticated(user),
    );
  }

  Future<void> register(String name, String email, String phone, String password) async {
    state = const AuthLoading();
    final result = await _registerUseCase(name, email, phone, password);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = Authenticated(user),
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();
    final result = await _logoutUseCase();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const Unauthenticated(),
    );
  }

  Future<void> updateProfile(String name, String phone, String address) async {
    if (state is Authenticated) {
      state = const AuthLoading();
      final result = await _updateProfileUseCase(name, phone, address);
      result.fold(
        (failure) => state = AuthError(failure.message),
        (user) => state = Authenticated(user),
      );
    }
  }
}

// Riverpod Provider Definition
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: sl<LoginUseCase>(),
    registerUseCase: sl<RegisterUseCase>(),
    logoutUseCase: sl<LogoutUseCase>(),
    getProfileUseCase: sl<GetProfileUseCase>(),
    updateProfileUseCase: sl<UpdateProfileUseCase>(),
  );
});
