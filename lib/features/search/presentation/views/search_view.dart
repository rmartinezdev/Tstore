import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/core/widgets/product_card.dart';
import 'package:tstore/core/widgets/responsive_layout.dart';
import 'package:tstore/features/categories/presentation/providers/categories_provider.dart';
import 'package:tstore/features/products/presentation/providers/products_provider.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // Read current search filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentSearch = ref.read(productsNotifierProvider).search;
      _searchController.text = currentSearch;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    // If we scroll near the end of the page, load more products
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsNotifierProvider.notifier).loadNextPage();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(productsNotifierProvider.notifier).updateFilters(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsNotifierProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final isTablet = ResponsiveLayout.isTablet(context) || ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, SKU, marca...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(productsNotifierProvider.notifier).updateFilters(search: '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips and Sort Panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                // Category filter chip
                categoriesState.when(
                  data: (cats) {
                    final match = cats
                        .expand((c) => [c, ...c.subcategories])
                        .where((c) => c.id == state.categoryId);
                    final currentCat = match.isNotEmpty ? match.first : null;
                    
                    return FilterChip(
                      label: Text(currentCat != null ? currentCat.name : 'Categorías'),
                      selected: state.categoryId != null,
                      onSelected: (_) => _showCategoryFilterDialog(context, cats),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(width: 8),
                
                // Sort Dropdown
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.sortBy,
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Ordenar por: A-Z')),
                          DropdownMenuItem(value: 'price_asc', child: Text('Precio: Menor a Mayor')),
                          DropdownMenuItem(value: 'price_desc', child: Text('Precio: Mayor a Menor')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(productsNotifierProvider.notifier).updateFilters(sortBy: val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main list or grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(productsNotifierProvider.notifier).loadNextPage(forceRefresh: true);
              },
              child: state.products.isEmpty && !state.isLoading
                  ? _buildEmptyState()
                  : _isGridView
                      ? _buildGrid(state.products, isTablet)
                      : _buildList(state.products),
            ),
          ),

          // Bottom Loading indicator
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No encontramos productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Prueba cambiando los filtros o palabra de búsqueda', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              ref.read(productsNotifierProvider.notifier).clearFilters();
            },
            child: const Text('Limpiar Filtros'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<dynamic> products, bool isTablet) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.60,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }

  Widget _buildList(List<dynamic> products) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => context.push('/product/${product.id}'),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.brand, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('\$${product.priceOffer.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        if (product.discount > 0) ...[
                          const SizedBox(width: 8),
                          Text('\$${product.priceNormal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryFilterDialog(BuildContext context, List<dynamic> roots) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por Categoría'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Todas las Categorías'),
                  onTap: () {
                    ref.read(productsNotifierProvider.notifier).updateFilters(categoryId: null);
                    Navigator.pop(context);
                  },
                ),
                ...roots.expand((root) => [
                      ListTile(
                        title: Text(root.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          ref.read(productsNotifierProvider.notifier).updateFilters(categoryId: root.id);
                          Navigator.pop(context);
                        },
                      ),
                      ...root.subcategories.map((sub) => ListTile(
                            contentPadding: const EdgeInsets.only(left: 32),
                            title: Text(sub.name),
                            onTap: () {
                              ref.read(productsNotifierProvider.notifier).updateFilters(categoryId: sub.id);
                              Navigator.pop(context);
                            },
                          )),
                    ]),
              ],
            ),
          ),
        );
      },
    );
  }
}
