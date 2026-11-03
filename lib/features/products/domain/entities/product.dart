class Product {
  final int id;
  final String name;
  final String sku;
  final String internalCode;
  final int categoryId;
  final String brand;
  final String shortDescription;
  final String descriptionHtml;
  final double priceNormal;
  final double priceOffer;
  final double discount;
  final int stock;
  final String availability;
  final double weight;
  final String imageUrl;
  final List<String> gallery;
  final List<String> videos;
  final List<String> documents;
  final Map<String, dynamic> attributes;
  final bool isFeatured;
  final bool isNew;
  final bool isOffer;
  final List<int> relatedProductIds;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.internalCode,
    required this.categoryId,
    required this.brand,
    required this.shortDescription,
    required this.descriptionHtml,
    required this.priceNormal,
    required this.priceOffer,
    required this.discount,
    required this.stock,
    required this.availability,
    required this.weight,
    required this.imageUrl,
    required this.gallery,
    required this.videos,
    required this.documents,
    required this.attributes,
    required this.isFeatured,
    required this.isNew,
    required this.isOffer,
    required this.relatedProductIds,
  });

  bool get hasStock => stock > 0;
}
