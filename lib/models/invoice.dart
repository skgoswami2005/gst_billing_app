class Invoice {
  final String id;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String createdAt;

  Invoice({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items,
      'totalAmount': totalAmount,
      'createdAt': createdAt,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      items: List<Map<String, dynamic>>.from(map['items']),
      totalAmount: map['totalAmount'],
      createdAt: map['createdAt'],
    );
  }
}
