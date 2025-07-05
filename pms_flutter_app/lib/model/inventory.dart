class Inventory {
  final int id;
  final String companyName;
  final String itemName;
  final String category;
  final String generic;
  final int quantity;
  final double unitPrice; // Using double for BigDecimal
  final double? purchaseDiscount; // Nullable
  final double? netPurchasePrice; // Nullable
  final double sellPrice;
  final double? totalInventoryValue; // Nullable
  final String?
  receivedDate;

  Inventory({
    required this.id,
    required this.companyName,
    required this.itemName,
    required this.category,
    required this.generic,
    required this.quantity,
    required this.unitPrice,
    this.purchaseDiscount,
    this.netPurchasePrice,
    required this.sellPrice,
    this.totalInventoryValue,
    this.receivedDate,
  });

  // Factory constructor to create an Inventory object from a JSON map
  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] as int,
      // Ensure proper casting
      companyName: json['companyName'] as String,
      itemName: json['itemName'] as String,
      category: json['category'] as String,
      generic: json['generic'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      // Ensure it's a double
      purchaseDiscount: (json['purchaseDiscount'] as num?)?.toDouble(),
      // Handle nullable
      netPurchasePrice: (json['netPurchasePrice'] as num?)?.toDouble(),
      // Handle nullable
      sellPrice: (json['sellPrice'] as num).toDouble(),
      // Ensure it's a double
      totalInventoryValue: (json['totalInventoryValue'] as num?)?.toDouble(),
      // Handle nullable
      receivedDate: json['receivedDate'] as String?,
    );
  }
}