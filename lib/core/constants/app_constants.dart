class AppConstants {
  AppConstants._();

  // App Name
  static const String appName = 'TStore';

  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String registerEndpoint = '/api/auth/register';
  static const String refreshEndpoint = '/api/auth/refresh';
  static const String profileEndpoint = '/api/auth/profile';

  static const String productsEndpoint = '/api/products';
  static const String categoriesEndpoint = '/api/categories';
  static const String cartEndpoint = '/api/cart';
  static const String favoritesEndpoint = '/api/favorites';
  static const String ordersEndpoint = '/api/orders';
  static const String customerEndpoint = '/api/customer';
  static const String configEndpoint = '/api/config';

  // Secure Storage Keys
  static const String tokenKey = 'jwt_access_token';
  static const String refreshTokenKey = 'jwt_refresh_token';
  static const String userSessionKey = 'user_session_data';

  // Hive Box Names
  static const String productsBox = 'products_cache_box';
  static const String categoriesBox = 'categories_cache_box';
  static const String cartBox = 'cart_local_box';
  static const String favoritesBox = 'favorites_local_box';
  static const String ordersBox = 'orders_cache_box';
  static const String appConfigBox = 'app_config_box';

  // Theme Dimensions
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double inputRadius = 12.0;
  
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Placeholder URLs
  static const String placeholderImageUrl = 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=500&auto=format&fit=crop&q=60';
  static const String fallbackProductImage = 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&auto=format&fit=crop&q=60';
}
