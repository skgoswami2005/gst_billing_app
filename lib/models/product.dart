class Product {
  final String id;
  final String name;
  final double price;
  final double gstPercentage;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.gstPercentage,
  });

  double get cgst => (price * gstPercentage / 100) / 2;
  double get sgst => (price * gstPercentage / 100) / 2;
  double get totalPrice => price + cgst + sgst;
}
