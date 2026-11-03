import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/features/authentication/presentation/providers/auth_provider.dart';
import 'package:tstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:tstore/features/orders/presentation/providers/orders_provider.dart';

class CheckoutView extends ConsumerStatefulWidget {
  const CheckoutView({super.key});

  @override
  ConsumerState<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<CheckoutView> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (auth is Authenticated) {
        _addressController.text = auth.user.address;
        _phoneController.text = auth.user.phone;
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _confirmCheckout() async {
    final success = await ref.read(ordersNotifierProvider.notifier).checkout();
    if (success) {
      // Clear the local cart notifier state on success
      ref.read(cartNotifierProvider.notifier).clearCart();
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final lastOrder = ref.read(ordersNotifierProvider).orders.first;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, size: 64, color: Colors.green),
          title: const Text('¡Pedido Confirmado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tu pedido ${lastOrder.name} ha sido enviado con éxito a Odoo.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hemos generado tu factura borrador en el sistema. Puedes consultar el detalle en tu historial de pedidos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(ordersNotifierProvider.notifier).resetCheckoutStatus();
                Navigator.pop(context); // Close dialog
                context.go('/'); // Go back to Home
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final ordersState = ref.watch(ordersNotifierProvider);

    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: Text('Redirigiendo a inicio de sesión...')),
      );
    }

    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
      ),
      body: ordersState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Client Info block
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text('Datos del Cliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const Divider(height: 24),
                          Text('Nombre: ${user.name}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Correo: ${user.email}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Shipping Address block (Editable)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.local_shipping, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text('Dirección de Envío', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const Divider(height: 24),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Dirección Completa',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono de contacto',
                              prefixIcon: Icon(Icons.phone),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Billing Summary details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.credit_card, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text('Resumen de Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const Divider(height: 24),
                          ...cartState.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.quantity} x ${item.product.name}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text('\$${item.subtotal.toStringAsFixed(2)}'),
                                  ],
                                ),
                              )),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total a Pagar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                '\$${cartState.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. Place Order button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _confirmCheckout,
                      child: const Text(
                        'Confirmar y Finalizar Pedido',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  
                  if (ordersState.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      ordersState.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
