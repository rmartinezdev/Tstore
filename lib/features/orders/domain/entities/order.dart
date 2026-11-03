class Order {
  final int id;
  final String name;
  final String date;
  final String state;
  final double total;
  final List<dynamic> items;
  final String? invoiceUrl;

  const Order({
    required this.id,
    required this.name,
    required this.date,
    required this.state,
    required this.total,
    required this.items,
    this.invoiceUrl,
  });

  String get stateText {
    switch (state.toLowerCase()) {
      case 'draft':
        return 'Borrador';
      case 'confirmed':
        return 'Confirmado';
      case 'paid':
        return 'Pagado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Pendiente';
    }
  }
}
