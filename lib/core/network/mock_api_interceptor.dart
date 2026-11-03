import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tstore/core/network/mock_data.dart';
import 'package:tstore/core/utils/logger.dart';

class MockApiInterceptor extends Interceptor {
  // In-memory cart and favorites lists for the active session to simulate CRUD operations
  static final List<Map<String, dynamic>> _mockCart = [];
  static final List<int> _mockFavorites = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    final method = options.method.toUpperCase();
    
    Log.info('Mock Request: [$method] $path Query: ${options.queryParameters} Body: ${options.data}');

    // Simulate Network Latency
    await Future.delayed(const Duration(milliseconds: 600));

    // Router
    try {
      // 1. AUTHENTICATION
      if (path.endsWith('/api/auth/login') && method == 'POST') {
        final data = _parseBody(options.data);
        final username = data['username'] ?? data['email'] ?? '';
        final password = data['password'] ?? '';

        if (username.isNotEmpty && password.isNotEmpty) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'success': true,
              'token': MockData.mockProfile['token'],
              'refresh_token': MockData.mockProfile['refresh_token'],
              'user': MockData.mockProfile
            },
          ));
          return;
        } else {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 400,
            data: {'success': false, 'message': 'Usuario/Email y contraseña son requeridos'},
          ));
          return;
        }
      }

      if (path.endsWith('/api/auth/logout') && method == 'POST') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'message': 'Sesión cerrada'},
        ));
        return;
      }

      if (path.endsWith('/api/auth/refresh') && method == 'POST') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'token': 'new-mock-jwt-access-token-secret-12345',
            'refresh_token': 'new-mock-jwt-refresh-token-secret-67890'
          },
        ));
        return;
      }

      if (path.endsWith('/api/auth/profile') && method == 'GET') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'user': MockData.mockProfile},
        ));
        return;
      }

      // 2. CONFIGURATION
      if (path.endsWith('/api/config') && method == 'GET') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'config': {
              'company_name': 'TStore Importaciones',
              'currency': 'USD',
              'currency_symbol': '\$',
              'terms_and_conditions': 'Términos y condiciones de uso del e-commerce...',
              'support_phone': '+54 9 11 5555-9999',
            }
          },
        ));
        return;
      }

      // 3. CATEGORIES
      if (path.endsWith('/api/categories/tree') && method == 'GET') {
        // Return hierarchy tree
        final rootCategories = MockData.categories.where((c) => c['parent_id'] == null).toList();
        final result = rootCategories.map((root) {
          final children = MockData.categories.where((c) => c['parent_id'] == root['id']).toList();
          return {
            ...root,
            'subcategories': children,
          };
        }).toList();

        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'categories': result},
        ));
        return;
      }

      if (path.endsWith('/api/categories') && method == 'GET') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'categories': MockData.categories},
        ));
        return;
      }

      // 4. PRODUCTS
      if (path.contains('/api/products') && method == 'GET') {
        // Check for specific ID
        final match = RegExp(r'/api/products/(\d+)$').firstMatch(path);
        if (match != null) {
          final id = int.parse(match.group(1)!);
          final product = MockData.products.firstWhere(
            (p) => p['id'] == id,
            orElse: () => <String, dynamic>{},
          );

          if (product.isNotEmpty) {
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true, 'product': product},
            ));
          } else {
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 404,
              data: {'success': false, 'message': 'Producto no encontrado'},
            ));
          }
          return;
        }

        // List / Query
        var filteredList = List<Map<String, dynamic>>.from(MockData.products);

        // Filters
        final queryParams = options.queryParameters;
        if (queryParams.containsKey('category_id')) {
          final catId = int.tryParse(queryParams['category_id'].toString());
          if (catId != null) {
            // Include category or its subcategories
            final subCatIds = MockData.categories
                .where((c) => c['parent_id'] == catId)
                .map((c) => c['id'] as int)
                .toList();
            filteredList = filteredList.where((p) {
              final pCat = p['category_id'] as int;
              return pCat == catId || subCatIds.contains(pCat);
            }).toList();
          }
        }

        if (queryParams.containsKey('search')) {
          final search = queryParams['search'].toString().toLowerCase().trim();
          if (search.isNotEmpty) {
            filteredList = filteredList.where((p) {
              final name = p['name'].toString().toLowerCase();
              final sku = p['sku'].toString().toLowerCase();
              final brand = p['brand'].toString().toLowerCase();
              return name.contains(search) || sku.contains(search) || brand.contains(search);
            }).toList();
          }
        }

        if (queryParams.containsKey('brand')) {
          final brand = queryParams['brand'].toString().toLowerCase();
          filteredList = filteredList.where((p) => p['brand'].toString().toLowerCase() == brand).toList();
        }

        if (queryParams.containsKey('is_featured')) {
          filteredList = filteredList.where((p) => p['is_featured'] == true).toList();
        }
        if (queryParams.containsKey('is_new')) {
          filteredList = filteredList.where((p) => p['is_new'] == true).toList();
        }
        if (queryParams.containsKey('is_offer')) {
          filteredList = filteredList.where((p) => p['is_offer'] == true).toList();
        }

        // Sorting
        final sortBy = queryParams['sort_by']?.toString();
        if (sortBy == 'price_asc') {
          filteredList.sort((a, b) => (a['price_offer'] as num).compareTo(b['price_offer'] as num));
        } else if (sortBy == 'price_desc') {
          filteredList.sort((a, b) => (b['price_offer'] as num).compareTo(a['price_offer'] as num));
        } else if (sortBy == 'name') {
          filteredList.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
        }

        // Pagination
        final limit = int.tryParse(queryParams['limit']?.toString() ?? '10') ?? 10;
        final offset = int.tryParse(queryParams['offset']?.toString() ?? '0') ?? 0;
        
        final paginatedList = filteredList.skip(offset).take(limit).toList();

        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'products': paginatedList,
            'total_count': filteredList.length,
            'offset': offset,
            'limit': limit
          },
        ));
        return;
      }

      // 5. CART OPERATIONS
      if (path.contains('/api/cart')) {
        if (method == 'GET') {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'cart': _mockCart},
          ));
          return;
        }

        if (method == 'POST' && path.endsWith('/api/cart/add')) {
          final data = _parseBody(options.data);
          final productId = int.tryParse(data['product_id']?.toString() ?? '');
          final quantity = int.tryParse(data['quantity']?.toString() ?? '1') ?? 1;

          if (productId != null) {
            final product = MockData.products.firstWhere(
              (p) => p['id'] == productId,
              orElse: () => <String, dynamic>{},
            );

            if (product.isNotEmpty) {
              final existingIndex = _mockCart.indexWhere((item) => item['product_id'] == productId);
              if (existingIndex != -1) {
                _mockCart[existingIndex]['quantity'] += quantity;
              } else {
                _mockCart.add({
                  'product_id': productId,
                  'quantity': quantity,
                  'product': product,
                });
              }

              handler.resolve(Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'cart': _mockCart},
              ));
            } else {
              handler.resolve(Response(
                requestOptions: options,
                statusCode: 404,
                data: {'success': false, 'message': 'Producto no encontrado'},
              ));
            }
          }
          return;
        }

        if (method == 'PUT' && path.endsWith('/api/cart/update')) {
          final data = _parseBody(options.data);
          final productId = int.tryParse(data['product_id']?.toString() ?? '');
          final quantity = int.tryParse(data['quantity']?.toString() ?? '1') ?? 1;

          if (productId != null) {
            final existingIndex = _mockCart.indexWhere((item) => item['product_id'] == productId);
            if (existingIndex != -1) {
              if (quantity <= 0) {
                _mockCart.removeAt(existingIndex);
              } else {
                _mockCart[existingIndex]['quantity'] = quantity;
              }
              handler.resolve(Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'cart': _mockCart},
              ));
            } else {
              handler.resolve(Response(
                requestOptions: options,
                statusCode: 404,
                data: {'success': false, 'message': 'Item no encontrado en el carrito'},
              ));
            }
          }
          return;
        }

        if (method == 'DELETE' && path.contains('/api/cart/remove')) {
          final data = _parseBody(options.data);
          final productId = int.tryParse(data['product_id']?.toString() ?? '');

          if (productId != null) {
            _mockCart.removeWhere((item) => item['product_id'] == productId);
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true, 'cart': _mockCart},
            ));
          }
          return;
        }

        if (method == 'DELETE' && path.endsWith('/api/cart/clear')) {
          _mockCart.clear();
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'cart': _mockCart},
          ));
          return;
        }
      }

      // 6. FAVORITES
      if (path.contains('/api/favorites')) {
        if (method == 'GET') {
          final favProducts = MockData.products.where((p) => _mockFavorites.contains(p['id'])).toList();
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'favorites': favProducts},
          ));
          return;
        }

        if (method == 'POST' && path.endsWith('/api/favorites/add')) {
          final data = _parseBody(options.data);
          final productId = int.tryParse(data['product_id']?.toString() ?? '');
          if (productId != null) {
            if (!_mockFavorites.contains(productId)) {
              _mockFavorites.add(productId);
            }
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true, 'favorites_ids': _mockFavorites},
            ));
          }
          return;
        }

        if (method == 'DELETE' && path.endsWith('/api/favorites/remove')) {
          final data = _parseBody(options.data);
          final productId = int.tryParse(data['product_id']?.toString() ?? '');
          if (productId != null) {
            _mockFavorites.remove(productId);
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true, 'favorites_ids': _mockFavorites},
            ));
          }
          return;
        }
      }

      // 7. ORDERS
      if (path.contains('/api/orders')) {
        if (method == 'POST' && path.endsWith('/api/orders/create')) {
          // Checkout validation - check if cart is empty
          if (_mockCart.isEmpty) {
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 400,
              data: {'success': false, 'message': 'El carrito está vacío'},
            ));
            return;
          }

          final orderId = 1000 + DateTime.now().millisecond;
          final total = _mockCart.fold<double>(
            0,
            (sum, item) => sum + ((item['product']['price_offer'] as num).toDouble() * (item['quantity'] as int)),
          );

          final mockOrder = {
            'id': orderId,
            'name': 'SO-$orderId',
            'date': DateTime.now().toIso8601String(),
            'state': 'draft', // draft, confirmed, paid, cancelled
            'total': total,
            'items': List.from(_mockCart),
            'invoice_url': 'https://pdf-invoice-mock.s3.amazonaws.com/invoice-$orderId.pdf'
          };

          // Clear local mock cart after order placement
          _mockCart.clear();

          handler.resolve(Response(
            requestOptions: options,
            statusCode: 201,
            data: {'success': true, 'order': mockOrder},
          ));
          return;
        }

        if (method == 'GET') {
          // For now, return a list of dummy orders or empty
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'success': true,
              'orders': [
                {
                  'id': 1001,
                  'name': 'SO-1001',
                  'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
                  'state': 'confirmed',
                  'total': 1399.00,
                  'items': [
                    {
                      'product_id': 101,
                      'quantity': 1,
                      'product': MockData.products[0]
                    }
                  ],
                  'invoice_url': 'https://pdf-invoice-mock.s3.amazonaws.com/invoice-1001.pdf'
                }
              ]
            },
          ));
          return;
        }
      }

      // 8. CUSTOMER UPDATE
      if (path.contains('/api/customer/update') && method == 'PUT') {
        final data = _parseBody(options.data);
        MockData.mockProfile.addAll(data);
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'user': MockData.mockProfile},
        ));
        return;
      }

      // Fallback
      handler.reject(DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 404,
          data: {'success': false, 'message': 'Ruta de Mock no encontrada'},
        ),
      ));
    } catch (e, stackTrace) {
      Log.error('Mock error on endpoint: $path', error: e, stackTrace: stackTrace);
      handler.reject(DioException(
        requestOptions: options,
        error: e,
        response: Response(
          requestOptions: options,
          statusCode: 500,
          data: {'success': false, 'message': 'Internal Mock Server Error'},
        ),
      ));
    }
  }

  Map<String, dynamic> _parseBody(dynamic body) {
    if (body == null) return {};
    if (body is Map<String, dynamic>) return body;
    if (body is String) {
      try {
        return jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {}
    }
    return {};
  }
}
