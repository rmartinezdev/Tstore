import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/core/widgets/product_card.dart';
import 'package:tstore/core/widgets/responsive_layout.dart';
import 'package:tstore/features/favorites/presentation/providers/favorites_provider.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesNotifierProvider);
    final isTablet = ResponsiveLayout.isTablet(context) || ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
      ),
      body: favorites.isEmpty
          ? _buildEmptyState(context)
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.60,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return ProductCard(product: favorites[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No tienes favoritos todavía', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Guarda los productos que te interesen para verlos o comprarlos más tarde.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Explorar Ofertas'),
            ),
          ],
        ),
      ),
    );
  }
}
