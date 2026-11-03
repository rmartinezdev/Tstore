import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/core/widgets/responsive_layout.dart';
import 'package:tstore/features/cart/presentation/providers/cart_provider.dart';

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final isTablet = ResponsiveLayout.isTablet(context) || ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () => _confirmClearCart(context, ref),
            ),
        ],
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartState.items.isEmpty
              ? _buildEmptyCart(context)
              : isTablet
                  ? _buildTabletLayout(context, ref, cartState)
                  : _buildMobileLayout(context, ref, cartState),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text('Tu carrito está vacío', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Explora nuestra tienda y encuentra las mejores ofertas importadas para ti.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Explorar Tienda'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, CartState state) {
    return Column(
      children: [
        // Items list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildCartItemCard(context, ref, state.items[index]);
            },
          ),
        ),
        
        // Checkout summary block
        _buildCheckoutSummary(context, state),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref, CartState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Items list
        Expanded(
          flex: 3,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildCartItemCard(context, ref, state.items[index]);
            },
          ),
        ),
        
        // Right Column: Summary card
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: _buildCheckoutSummary(context, state, isVertical: true),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(BuildContext context, WidgetRef ref, dynamic item) {
    final product = item.product;

    return Dismissible(
      key: Key(item.productId.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(cartNotifierProvider.notifier).removeFromCart(item.productId);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey, height: 80, width: 80),
              ),
            ),
            const SizedBox(width: 16),
            
            // Name, SKU, Prices, Qty Selectors
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    'SKU: ${product.sku}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.priceOffer.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      
                      // Quantity control
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: item.quantity > 1
                                  ? () => ref.read(cartNotifierProvider.notifier).updateQuantity(item.productId, item.quantity - 1)
                                  : null,
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: item.quantity < product.stock
                                  ? () => ref.read(cartNotifierProvider.notifier).updateQuantity(item.productId, item.quantity + 1)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSummary(BuildContext context, CartState state, {bool isVertical = false}) {
    final totalsWidget = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Resumen de Compra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Productos'),
              Text('${state.itemsCount} unidades'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('\$${state.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Estimado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '\$${state.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Checkout Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                // Checkout redirects automatically via GoRouter if unauthenticated
                context.push('/checkout');
              },
              child: const Text('Proceder al Pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );

    if (isVertical) {
      return totalsWidget;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: SafeArea(child: totalsWidget),
    );
  }

  void _confirmClearCart(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar Carrito'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: const Text('Eliminar Todo', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
