import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/core/network/mock_data.dart';
import 'package:tstore/core/widgets/product_card.dart';
import 'package:tstore/core/widgets/shimmer_loading.dart';
import 'package:tstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:tstore/features/categories/presentation/providers/categories_provider.dart';
import 'package:tstore/features/products/presentation/providers/products_provider.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);
    final featuredState = ref.watch(featuredProductsProvider);
    final newState = ref.watch(newProductsProvider);
    final offersState = ref.watch(offerProductsProvider);
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tramontina TStore'),
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(newProductsProvider);
          ref.invalidate(offerProductsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Text('Buscar productos, marcas y SKU...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Banner Slider (Horizontal Carousels)
              _buildBannersSection(),

              // 3. Quick Categories list
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Explorar Categorías', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              categoriesState.when(
                data: (list) => _buildQuickCategories(context, ref, list),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ShimmerLoading.rectangular(width: double.infinity, height: 80),
                ),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),

              // 4. Banners/Promotions Section
              const SizedBox(height: 12),

              // 5. Featured Carousel
              _buildProductSection(
                title: 'Productos Destacados',
                state: featuredState,
                onSeeAll: () {
                  ref.read(productsNotifierProvider.notifier).updateFilters(sortBy: 'name');
                  context.push('/search');
                },
              ),

              // 6. Offers Carousel
              _buildProductSection(
                title: 'Ofertas Imperdibles',
                state: offersState,
                onSeeAll: () {
                  ref.read(productsNotifierProvider.notifier).updateFilters(sortBy: 'price_asc');
                  context.push('/search');
                },
              ),

              // 7. New Carousel
              _buildProductSection(
                title: 'Recién Llegados',
                state: newState,
                onSeeAll: () {
                  ref.read(productsNotifierProvider.notifier).updateFilters(sortBy: 'name');
                  context.push('/search');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannersSection() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: MockData.banners.length,
        itemBuilder: (context, index) {
          final banner = MockData.banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(banner['image_url']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      banner['title'],
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      banner['subtitle'],
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickCategories(BuildContext context, WidgetRef ref, List<dynamic> categories) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              // Set search category filter
              ref.read(productsNotifierProvider.notifier).updateFilters(categoryId: category.id);
              context.push('/search');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(category.imageUrl ?? ''),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSection({
    required String title,
    required AsyncValue<List<dynamic>> state,
    required VoidCallback onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: onSeeAll, child: const Text('Ver Todo')),
            ],
          ),
        ),
        state.when(
          data: (products) => SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ProductCard(product: products[index]),
                );
              },
            ),
          ),
          loading: () => SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 4,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: ShimmerLoading.rectangular(width: 180, height: 280),
              ),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No se pudieron cargar los productos: $err'),
          ),
        ),
      ],
    );
  }
}
