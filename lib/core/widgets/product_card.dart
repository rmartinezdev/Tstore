import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/core/theme/app_theme.dart';
import 'package:tstore/core/widgets/shimmer_loading.dart';
import 'package:tstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:tstore/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:tstore/features/products/domain/entities/product.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesNotifierProvider);
    final isFav = favorites.any((p) => p.id == product.id);
    
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerLoading.rectangular(
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Image.network(
                        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&auto=format&fit=crop&q=60',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Badges
                if (product.discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${product.discount.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (product.isNew)
                  Positioned(
                    top: 8,
                    left: product.discount > 0 ? 50 : 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NUEVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Favorite Button
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.black87,
                        size: 20,
                      ),
                      onPressed: () {
                        ref.read(favoritesNotifierProvider.notifier).toggleFavorite(product);
                      },
                    ),
                  ),
                ),
              ],
            ),
            ),
            
            // Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Prices Row
                  Row(
                    children: [
                      Text(
                        '\$${product.priceOffer.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (product.discount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.priceNormal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: product.hasStock
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: product.hasStock
                          ? () {
                              ref.read(cartNotifierProvider.notifier).addToCart(product, 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} agregado al carrito'),
                                  duration: const Duration(seconds: 1),
                                  action: SnackBarAction(
                                    label: 'Ir',
                                    textColor: Colors.white,
                                    onPressed: () => context.push('/cart'),
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        product.hasStock ? 'Comprar' : 'Agotado',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
