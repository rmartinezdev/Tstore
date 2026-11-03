import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/core/widgets/product_card.dart';
import 'package:tstore/core/widgets/shimmer_loading.dart';
import 'package:tstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:tstore/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:tstore/features/products/domain/entities/product.dart';
import 'package:tstore/features/products/presentation/providers/products_provider.dart';

class ProductDetailView extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailView({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<ProductDetailView> {
  int _quantity = 1;
  int _activeGalleryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(productDetailProvider(widget.productId));
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Producto'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cartState.itemsCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    child: Text(
                      '${cartState.itemsCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: detailState.when(
        data: (product) => _buildDetailContent(context, product),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error al cargar producto: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(productDetailProvider(widget.productId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Product product) {
    final favorites = ref.watch(favoritesNotifierProvider);
    final isFav = favorites.any((p) => p.id == product.id);
    final gallery = product.gallery.isNotEmpty ? product.gallery : [product.imageUrl];

    return Column(
      children: [
        // Main scrollable details
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image gallery pageview
                Stack(
                  children: [
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        itemCount: gallery.length,
                        onPageChanged: (idx) => setState(() => _activeGalleryIndex = idx),
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: gallery[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => const ShimmerLoading.rectangular(
                              width: double.infinity,
                              height: 300,
                            ),
                          );
                        },
                      ),
                    ),
                    // Indicators
                    if (gallery.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: gallery.asMap().entries.map((entry) {
                            final idx = entry.key;
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _activeGalleryIndex == idx
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white.withOpacity(0.5),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    // Heart icon
                    Positioned(
                      top: 12,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.black87,
                          ),
                          onPressed: () {
                            ref.read(favoritesNotifierProvider.notifier).toggleFavorite(product);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Core Product Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SKU & Code tags
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SKU: ${product.sku}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Cod: ${product.internalCode}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        product.brand.toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Prices block
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '\$${product.priceOffer.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                          ),
                          if (product.discount > 0) ...[
                            const SizedBox(width: 12),
                            Text(
                              '\$${product.priceNormal.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade500, decoration: TextDecoration.lineThrough),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${product.discount.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stock & Availability status
                      _buildStockPanel(product),

                      const Divider(height: 32),

                      // HTML Description rendering
                      const Text(
                        'Descripción del producto',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      HtmlWidget(
                        product.descriptionHtml.isNotEmpty
                            ? product.descriptionHtml
                            : '<p>${product.shortDescription}</p>',
                        textStyle: const TextStyle(fontSize: 14, height: 1.5),
                      ),

                      // Technical Attributes Table
                      if (product.attributes.isNotEmpty) ...[
                        const Divider(height: 32),
                        const Text(
                          'Especificaciones técnicas',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildAttributesTable(product.attributes),
                      ],

                      // Related Products section
                      if (product.relatedProductIds.isNotEmpty) ...[
                        const Divider(height: 32),
                        const Text(
                          'Productos relacionados',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildRelatedSection(product.relatedProductIds),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Add to Cart Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              // Quantity Selector
              if (product.hasStock) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
              
              // Action Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: product.hasStock ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                    ),
                    onPressed: product.hasStock
                        ? () {
                            ref.read(cartNotifierProvider.notifier).addToCart(product, _quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$_quantity x ${product.name} agregados al carrito'),
                                action: SnackBarAction(
                                  label: 'Ver',
                                  textColor: Colors.white,
                                  onPressed: () => context.push('/cart'),
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      product.hasStock ? 'Agregar al Carrito' : 'Agotado',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockPanel(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: product.hasStock ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            product.hasStock ? Icons.check_circle_outline : Icons.error_outline,
            color: product.hasStock ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.hasStock ? 'Disponible - ${product.availability}' : 'Agotado Temporalmente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: product.hasStock ? Colors.green.shade800 : Colors.red.shade800,
                  fontSize: 13,
                ),
              ),
              if (product.hasStock)
                Text(
                  'Quedan ${product.stock} unidades en el almacén',
                  style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesTable(Map<String, dynamic> attributes) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, width: 1, borderRadius: BorderRadius.circular(8)),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: attributes.entries.map((entry) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(entry.value.toString(), style: const TextStyle(fontSize: 13)),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRelatedSection(List<int> ids) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ids.length,
        itemBuilder: (context, index) {
          final id = ids[index];
          
          return Consumer(
            builder: (context, ref, _) {
              final relatedState = ref.watch(productDetailProvider(id));
              
              return relatedState.when(
                data: (product) => Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ProductCard(product: product, width: 160),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: ShimmerLoading.rectangular(width: 160, height: 250),
                ),
                error: (_, __) => const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }
}
