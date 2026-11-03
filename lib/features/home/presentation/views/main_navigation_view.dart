import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tstore/core/widgets/responsive_layout.dart';
import 'package:tstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:tstore/features/home/presentation/views/home_view.dart';
import 'package:tstore/features/categories/presentation/views/categories_view.dart';
import 'package:tstore/features/favorites/presentation/views/favorites_view.dart';
import 'package:tstore/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:tstore/features/profile/presentation/views/profile_view.dart';
import 'package:go_router/go_router.dart';

class MainNavigationView extends ConsumerStatefulWidget {
  const MainNavigationView({super.key});

  @override
  ConsumerState<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends ConsumerState<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const HomeView(),
    const CategoriesView(),
    const FavoritesView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final isTablet = ResponsiveLayout.isTablet(context) || ResponsiveLayout.isDesktop(context);

    if (isTablet) {
      // Tablet/Desktop Layout: Navigation Rail Sidebar
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.shopping_bag, color: Theme.of(context).colorScheme.primary),
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          onPressed: () => context.push('/cart'),
                        ),
                        if (cartState.itemsCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Theme.of(context).colorScheme.tertiary,
                              child: Text(
                                '${cartState.itemsCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Inicio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.category_outlined),
                  selectedIcon: Icon(Icons.category),
                  label: Text('Categorías'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_outline),
                  selectedIcon: Icon(Icons.favorite),
                  label: Text('Favoritos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Perfil'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _views[_currentIndex]),
          ],
        ),
      );
    }

    // Phone Layout: Bottom Navigation Bar
    return Scaffold(
      body: _views[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: ref.watch(favoritesNotifierProvider).isNotEmpty
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_outline),
            label: 'Favoritos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
