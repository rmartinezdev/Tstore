import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/core/config/dependency_injection.dart';
import 'package:tstore/core/network/jwt_handler.dart';

// Presentation routes placeholder (will be replaced or linked to screens)
import 'package:tstore/features/authentication/presentation/views/login_view.dart';
import 'package:tstore/features/authentication/presentation/views/register_view.dart';
import 'package:tstore/features/home/presentation/views/main_navigation_view.dart';
import 'package:tstore/features/products/presentation/views/product_detail_view.dart';
import 'package:tstore/features/cart/presentation/views/cart_view.dart';
import 'package:tstore/features/checkout/presentation/views/checkout_view.dart';
import 'package:tstore/features/orders/presentation/views/orders_view.dart';
import 'package:tstore/features/search/presentation/views/search_view.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) async {
      final jwtHandler = sl<JwtHandler>();
      final isAuthenticated = await jwtHandler.hasToken();
      final isCheckingOut = state.matchedLocation == '/checkout';

      if (isCheckingOut && !isAuthenticated) {
        // Redirect to login if user tries to checkout unauthenticated
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ProductDetailView(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartView(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutView(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersView(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchView(),
      ),
    ],
  );
}
