import 'package:tstore/features/orders/domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.name,
    required super.date,
    required super.state,
    required super.total,
    required super.items,
    super.invoiceUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      state: json['state'] as String? ?? '',
      total: (json['total'] as num? ?? 0.0).toDouble(),
      items: json['items'] as List? ?? [],
      invoiceUrl: json['invoice_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'state': state,
      'total': total,
      'items': items,
      'invoice_url': invoiceUrl,
    };
  }
}
