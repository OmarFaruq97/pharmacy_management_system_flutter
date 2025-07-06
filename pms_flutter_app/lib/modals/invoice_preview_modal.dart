import 'package:flutter/material.dart';

class InvoicePreviewModal extends StatelessWidget {
  final String customerName;
  final String contactNumber;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final double discount;
  final double discountAmount;
  final double netPayable;

  const InvoicePreviewModal({
    super.key,
    required this.customerName,
    required this.contactNumber,
    required this.items,
    required this.totalAmount,
    required this.discount,
    required this.discountAmount,
    required this.netPayable,
  });

  static void show(
    BuildContext context, {
    required String customerName,
    required String contactNumber,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required double discount,
    required double discountAmount,
    required double netPayable,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 32,
        ),
        child: InvoicePreviewModal(
          customerName: customerName,
          contactNumber: contactNumber,
          items: items,
          totalAmount: totalAmount,
          discount: discount,
          discountAmount: discountAmount,
          netPayable: netPayable,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Invoice Preview",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("Customer: $customerName"),
          Text("Phone: $contactNumber"),
          const SizedBox(height: 10),
          const Divider(),
          const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...items.map(
            (item) => ListTile(
              title: Text('${item['itemName']} (${item['category']})'),
              subtitle: Text(
                'Qty: ${item['quantity']} | Unit: ${item['unitPrice']}',
              ),
              trailing: Text(
                'Subtotal: ${item['subTotal'].toStringAsFixed(2)}',
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          _summaryRow("Total Amount", totalAmount),
          _summaryRow("Discount (%)", discount),
          _summaryRow("Discount Amount", discountAmount),
          _summaryRow("Net Payable", netPayable, bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
