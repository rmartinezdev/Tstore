import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/features/authentication/presentation/providers/auth_provider.dart';
import 'package:tstore/features/cart/presentation/providers/cart_provider.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUserData(dynamic user) {
    _nameController.text = user.name;
    _phoneController.text = user.phone;
    _addressController.text = user.address;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).updateProfile(
            _nameController.text.trim(),
            _phoneController.text.trim(),
            _addressController.text.trim(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cartState = ref.watch(cartNotifierProvider);

    if (authState is! Authenticated) {
      return _buildUnauthenticatedBody();
    }

    final user = authState.user;
    
    // Load controller data if they are empty
    if (_nameController.text.isEmpty && user.name.isNotEmpty) {
      _loadUserData(user);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar and Name Header
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      user.name.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Profile actions
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.blueAccent),
                title: const Text('Mis Pedidos', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Ver historial de compras y facturas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/orders'),
              ),
            ),
            
            // Sync cart card
            Card(
              child: ListTile(
                leading: const Icon(Icons.sync, color: Colors.blueAccent),
                title: const Text('Sincronizar Datos', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Forzar sincronización de carrito y favoritos'),
                trailing: cartState.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right),
                onTap: () async {
                  await ref.read(cartNotifierProvider.notifier).syncCartOffline();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sincronización completada.')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Edit profile form
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Text('Información de Contacto y Envío', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                        validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Dirección de Entrega'),
                        maxLines: 2,
                        validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedBody() {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              const Text('Mi Cuenta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Inicia sesión para gestionar tus pedidos, revisar tus direcciones guardadas y sincronizar tus favoritos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
