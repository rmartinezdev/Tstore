import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tstore/features/orders/domain/entities/order.dart';
import 'package:tstore/features/orders/presentation/providers/orders_provider.dart';

class OrdersView extends ConsumerWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => ref.read(ordersNotifierProvider.notifier).loadOrders(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, state.orders[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No tienes pedidos aún', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Todas tus compras aparecerán listadas aquí.'),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    Color stateColor;
    switch (order.state.toLowerCase()) {
      case 'draft':
        stateColor = Colors.orange;
        break;
      case 'confirmed':
        stateColor = Colors.blue;
        break;
      case 'paid':
        stateColor = Colors.green;
        break;
      default:
        stateColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order No and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stateColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.stateText,
                    style: TextStyle(color: stateColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Date
            Text(
              'Fecha: ${order.date.substring(0, 10)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const Divider(height: 24),
            
            // Items Preview
            ...order.items.map((item) {
              final qty = item['quantity'] as int;
              final pName = item['product']['name'] as String;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$qty x $pName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      '\$${((item['product']['price_offer'] as num).toDouble() * qty).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 24),

            // Total billing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Facturado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            // Download PDF Invoice button
            if (order.invoiceUrl != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Open Invoice Link or trigger download alert
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Descargando factura en PDF de ${order.name}...')),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Descargar Factura PDF'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
