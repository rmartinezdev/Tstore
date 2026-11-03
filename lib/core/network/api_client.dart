import 'package:dio/dio.dart';
import 'package:tstore/core/config/env.dart';
import 'package:tstore/core/exceptions/failures.dart';
import 'package:tstore/core/network/jwt_handler.dart';
import 'package:tstore/core/network/mock_api_interceptor.dart';
import 'package:tstore/core/utils/logger.dart';

class ApiClient {
  final Dio _dio;
  final JwtHandler _jwtHandler;

  ApiClient(this._dio, this._jwtHandler) {
    _initClient();
  }

  void _initClient() {
    _dio.options = BaseOptions(
      baseUrl: Env.isMock ? 'http://mockserver' : Env.apiBaseUrl,
      connectTimeout: Duration(milliseconds: Env.apiTimeoutMs),
      receiveTimeout: Duration(milliseconds: Env.apiTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // If mock is active, inject Mock API interceptor
    if (Env.isMock) {
      _dio.interceptors.add(MockApiInterceptor());
    }

    // Security Interceptor for JWT Access Token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _jwtHandler.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Handle 401 Unauthorized for Refresh Token flow
        if (error.response?.statusCode == 401) {
          Log.info('JWT expired. Executing Refresh Token flow...');
          final refreshed = await _performRefreshToken();
          if (refreshed) {
            // Retry the original request
            final options = error.requestOptions;
            final newToken = await _jwtHandler.getToken();
            options.headers['Authorization'] = 'Bearer $newToken';
            
            try {
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
        }
        return handler.next(error);
      },
    ));

    // Logging in debug mode
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => Log.debug(obj.toString(), tag: 'API_LOG'),
    ));
  }

  Future<bool> _performRefreshToken() async {
    final refreshToken = await _jwtHandler.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      Log.warning('Refresh token missing. Session expired.');
      await _jwtHandler.clearTokens();
      return false;
    }

    try {
      // Create separate Dio instance to avoid recursive token intercepting
      final tempDio = Dio(BaseOptions(
        baseUrl: Env.isMock ? 'http://mockserver' : Env.apiBaseUrl,
        connectTimeout: Duration(milliseconds: Env.apiTimeoutMs),
      ));
      if (Env.isMock) {
        tempDio.interceptors.add(MockApiInterceptor());
      }

      final response = await tempDio.post('/api/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccessToken = data['token'];
        final newRefreshToken = data['refresh_token'];
        if (newAccessToken != null && newRefreshToken != null) {
          await _jwtHandler.saveToken(newAccessToken);
          await _jwtHandler.saveRefreshToken(newRefreshToken);
          Log.info('Token refreshed successfully.');
          return true;
        }
      }
    } catch (e) {
      Log.error('Error during refresh token flow', error: e);
    }

    await _jwtHandler.clearTokens();
    return false;
  }

  // GET HTTP Request wrapper
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST HTTP Request wrapper
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT HTTP Request wrapper
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE HTTP Request wrapper
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Exception mapper
  Failure _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure('Tiempo de espera agotado. Revisa tu conexión.');
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return const NetworkFailure('No se pudo establecer conexión con el servidor.');
    }

    if (error.response != null) {
      final code = error.response!.statusCode;
      final data = error.response!.data;
      String message = 'Ha ocurrido un error inesperado';

      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      }

      if (code == 401 || code == 403) {
        return AuthFailure(message, statusCode: code);
      }
      return ServerFailure(message, statusCode: code);
    }

    return ServerFailure(error.message ?? 'Error de conexión desconocido');
  }
}
