import 'package:tstore/features/categories/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.parentId,
    super.imageUrl,
    super.productsCount,
    super.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var subList = <Category>[];
    if (json['subcategories'] != null) {
      subList = (json['subcategories'] as List)
          .map((sub) => CategoryModel.fromJson(sub as Map<String, dynamic>))
          .toList();
    }

    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      parentId: json['parent_id'] as int?,
      imageUrl: json['image_url'] as String?,
      productsCount: json['products_count'] as int? ?? 0,
      subcategories: subList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'image_url': imageUrl,
      'products_count': productsCount,
      'subcategories': subcategories.map((sub) => (sub as CategoryModel).toJson()).toList(),
    };
  }
}
