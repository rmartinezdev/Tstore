import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/network/api_client.dart';
import 'package:tstore/core/network/jwt_handler.dart';
import 'package:tstore/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(String name, String email, String phone, String password);
  Future<void> logout();
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(String name, String phone, String address);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final JwtHandler _jwtHandler;

  AuthRemoteDataSourceImpl(this._apiClient, this._jwtHandler);

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await _apiClient.post(AppConstants.loginEndpoint, data: {
      'username': username,
      'password': password,
    });

    final data = response.data;
    final token = data['token'] as String;
    final refreshToken = data['refresh_token'] as String;

    // Save tokens securely
    await _jwtHandler.saveToken(token);
    await _jwtHandler.saveRefreshToken(refreshToken);

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register(String name, String email, String phone, String password) async {
    final response = await _apiClient.post(AppConstants.registerEndpoint, data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });

    final data = response.data;
    final token = data['token'] as String;
    final refreshToken = data['refresh_token'] as String;

    await _jwtHandler.saveToken(token);
    await _jwtHandler.saveRefreshToken(refreshToken);

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(AppConstants.logoutEndpoint);
    await _jwtHandler.clearTokens();
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(AppConstants.profileEndpoint);
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile(String name, String phone, String address) async {
    final response = await _apiClient.put('${AppConstants.customerEndpoint}/update', data: {
      'name': name,
      'phone': phone,
      'address': address,
    });
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }
}
