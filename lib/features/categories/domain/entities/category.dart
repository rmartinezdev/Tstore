class Category {
  final int id;
  final String name;
  final int? parentId;
  final String? imageUrl;
  final int productsCount;
  final List<Category> subcategories;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    this.imageUrl,
    this.productsCount = 0,
    this.subcategories = const [],
  });

  Category copyWith({List<Category>? subcategories}) {
    return Category(
      id: id,
      name: name,
      parentId: parentId,
      imageUrl: imageUrl,
      productsCount: productsCount,
      subcategories: subcategories ?? this.subcategories,
    );
  }
}
