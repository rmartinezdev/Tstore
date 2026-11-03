import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:tstore/core/network/api_client.dart';
import 'package:tstore/core/network/jwt_handler.dart';
import 'package:tstore/core/services/connectivity_service.dart';

// Authentication
import 'package:tstore/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:tstore/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:tstore/features/authentication/domain/repositories/auth_repository.dart';
import 'package:tstore/features/authentication/domain/usecases/login_use_case.dart';
import 'package:tstore/features/authentication/domain/usecases/register_use_case.dart';
import 'package:tstore/features/authentication/domain/usecases/logout_use_case.dart';
import 'package:tstore/features/authentication/domain/usecases/get_profile_use_case.dart';
import 'package:tstore/features/authentication/domain/usecases/update_profile_use_case.dart';

// Categories
import 'package:tstore/features/categories/data/datasources/categories_local_data_source.dart';
import 'package:tstore/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:tstore/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:tstore/features/categories/domain/repositories/categories_repository.dart';
import 'package:tstore/features/categories/domain/usecases/get_categories_tree_use_case.dart';

// Products
import 'package:tstore/features/products/data/datasources/products_local_data_source.dart';
import 'package:tstore/features/products/data/datasources/products_remote_data_source.dart';
import 'package:tstore/features/products/data/repositories/products_repository_impl.dart';
import 'package:tstore/features/products/domain/repositories/products_repository.dart';
import 'package:tstore/features/products/domain/usecases/get_products_use_case.dart';
import 'package:tstore/features/products/domain/usecases/get_product_detail_use_case.dart';
import 'package:tstore/features/products/domain/usecases/get_home_products_use_cases.dart';

// Cart
import 'package:tstore/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:tstore/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:tstore/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:tstore/features/cart/domain/repositories/cart_repository.dart';
import 'package:tstore/features/cart/domain/usecases/cart_usecases.dart';

// Favorites
import 'package:tstore/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:tstore/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:tstore/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:tstore/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tstore/features/favorites/domain/usecases/favorites_usecases.dart';

// Orders
import 'package:tstore/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:tstore/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:tstore/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:tstore/features/orders/domain/repositories/orders_repository.dart';
import 'package:tstore/features/orders/domain/usecases/orders_usecases.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> initDependencyInjection() async {
  // 1. External dependencies
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);
  
  final dio = Dio();
  sl.registerLazySingleton<Dio>(() => dio);

  // 2. Core services & components
  sl.registerLazySingleton<JwtHandler>(() => JwtHandler(sl<FlutterSecureStorage>()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>(), sl<JwtHandler>()));
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // 3. DataSources
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<ApiClient>(), sl<JwtHandler>()));
  
  // Categories
  sl.registerLazySingleton<CategoriesRemoteDataSource>(
      () => CategoriesRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<CategoriesLocalDataSource>(
      () => CategoriesLocalDataSourceImpl());

  // Products
  sl.registerLazySingleton<ProductsRemoteDataSource>(
      () => ProductsRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<ProductsLocalDataSource>(
      () => ProductsLocalDataSourceImpl());

  // Cart
  sl.registerLazySingleton<CartRemoteDataSource>(
      () => CartRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<CartLocalDataSource>(
      () => CartLocalDataSourceImpl());

  // Favorites
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
      () => FavoritesRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSourceImpl());

  // Orders
  sl.registerLazySingleton<OrdersRemoteDataSource>(
      () => OrdersRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<OrdersLocalDataSource>(
      () => OrdersLocalDataSourceImpl());

  // 4. Repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()));
  sl.registerLazySingleton<CategoriesRepository>(
      () => CategoriesRepositoryImpl(sl<CategoriesRemoteDataSource>(), sl<CategoriesLocalDataSource>(), sl<ConnectivityService>()));
  sl.registerLazySingleton<ProductsRepository>(
      () => ProductsRepositoryImpl(sl<ProductsRemoteDataSource>(), sl<ProductsLocalDataSource>(), sl<ConnectivityService>()));
  sl.registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(sl<CartRemoteDataSource>(), sl<CartLocalDataSource>(), sl<ProductsLocalDataSource>(), sl<ConnectivityService>()));
  sl.registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(sl<FavoritesRemoteDataSource>(), sl<FavoritesLocalDataSource>(), sl<ProductsLocalDataSource>(), sl<ConnectivityService>()));
  sl.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(sl<OrdersRemoteDataSource>(), sl<OrdersLocalDataSource>(), sl<ConnectivityService>()));

  // 5. Use Cases
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<AuthRepository>()));

  // Categories
  sl.registerLazySingleton(() => GetCategoriesTreeUseCase(sl<CategoriesRepository>()));

  // Products
  sl.registerLazySingleton(() => GetProductsUseCase(sl<ProductsRepository>()));
  sl.registerLazySingleton(() => GetProductDetailUseCase(sl<ProductsRepository>()));
  sl.registerLazySingleton(() => GetFeaturedProductsUseCase(sl<ProductsRepository>()));
  sl.registerLazySingleton(() => GetNewProductsUseCase(sl<ProductsRepository>()));
  sl.registerLazySingleton(() => GetOfferProductsUseCase(sl<ProductsRepository>()));

  // Cart
  sl.registerLazySingleton(() => GetCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => UpdateCartItemUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => SyncCartUseCase(sl<CartRepository>()));

  // Favorites
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl<FavoritesRepository>()));
  sl.registerLazySingleton(() => AddToFavoritesUseCase(sl<FavoritesRepository>()));
  sl.registerLazySingleton(() => RemoveFromFavoritesUseCase(sl<FavoritesRepository>()));
  sl.registerLazySingleton(() => IsFavoriteUseCase(sl<FavoritesRepository>()));

  // Orders
  sl.registerLazySingleton(() => GetOrdersUseCase(sl<OrdersRepository>()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl<OrdersRepository>()));
}
