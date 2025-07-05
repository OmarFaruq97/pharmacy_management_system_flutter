// model/invoice_history.dart
class InvoiceHistory {
  final String? invoiceNumber;
  final String customerName;
  final String contactNumber;
  final String itemName;
  final String category;
  final int quantity;
  final double unitPrice;
  final double subTotal;
  final double amount;
  final double discount;
  final double discountAmount;
  final double netPayable;

  InvoiceHistory({
    this.invoiceNumber,
    required this.customerName,
    required this.contactNumber,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.subTotal,
    required this.amount,
    required this.discount,
    required this.discountAmount,
    required this.netPayable,
  });

  Map<String, dynamic> toJson() => {
    "customerName": customerName,
    "contactNumber": contactNumber,
    "itemName": itemName,
    "category": category,
    "quantity": quantity,
    "unitPrice": unitPrice,
    "subTotal": subTotal,
    "amount": amount,
    "discount": discount,
    "discountAmount": discountAmount,
    "netPayable": netPayable,
  };

  factory InvoiceHistory.fromJson(Map<String, dynamic> json) {
    return InvoiceHistory(
      invoiceNumber: json['invoiceNumber'],
      customerName: json['customerName'],
      contactNumber: json['contactNumber'],
      itemName: json['itemName'],
      category: json['category'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      subTotal: json['subTotal'],
      amount: json['amount'],
      discount: json['discount'],
      discountAmount: json['discountAmount'],
      netPayable: json['netPayable'],
    );
  }
}
