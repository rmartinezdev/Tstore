import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tstore/features/categories/presentation/providers/categories_provider.dart';
import 'package:tstore/features/products/presentation/providers/products_provider.dart';

class CategoriesView extends ConsumerStatefulWidget {
  const CategoriesView({super.key});

  @override
  ConsumerState<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends ConsumerState<CategoriesView> {
  int _selectedRootIndex = 0;

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: categoriesState.when(
        data: (rootCategories) {
          if (rootCategories.isEmpty) {
            return const Center(child: Text('No hay categorías disponibles.'));
          }

          final activeRoot = rootCategories[_selectedRootIndex];

          return Row(
            children: [
              // Left sidebar: Root Categories
              Container(
                width: 110,
                color: Theme.of(context).cardColor,
                child: ListView.builder(
                  itemCount: rootCategories.length,
                  itemBuilder: (context, index) {
                    final cat = rootCategories[index];
                    final isSelected = index == _selectedRootIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedRootIndex = index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).scaffoldBackgroundColor
                              : Theme.of(context).cardColor,
                          border: isSelected
                              ? Border(
                                  left: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 4,
                                  ),
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(cat.imageUrl ?? ''),
                              backgroundColor: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const VerticalDivider(width: 1, thickness: 1),

              // Right Area: Grid of Subcategories
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header image or title
                      GestureDetector(
                        onTap: () {
                          // Search inside root category
                          ref.read(productsNotifierProvider.notifier).updateFilters(categoryId: activeRoot.id);
                          context.push('/search');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Theme.of(context).colorScheme.primary.withOpacity(0.8), Theme.of(context).colorScheme.secondary.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeRoot.name,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ver todos los productos (${activeRoot.productsCount})',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Subcategorías',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Subcategories Grid
                      Expanded(
                        child: activeRoot.subcategories.isEmpty
                            ? Center(
                                child: Text('No hay subcategorías en ${activeRoot.name}'),
                              )
                            : GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: activeRoot.subcategories.length,
                                itemBuilder: (context, index) {
                                  final sub = activeRoot.subcategories[index];

                                  return GestureDetector(
                                    onTap: () {
                                      ref.read(productsNotifierProvider.notifier).updateFilters(categoryId: sub.id);
                                      context.push('/search');
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              sub.imageUrl ?? '',
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: Colors.grey.shade200,
                                                height: 60,
                                                width: 60,
                                                child: const Icon(Icons.category, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            sub.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${sub.productsCount} productos',
                                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Text('Error al cargar categorías: $err'),
        ),
      ),
    );
  }
}
