// import 'package:flutter/material.dart';
//
// class InvoicePreviewModal extends StatelessWidget {
//   final String customerName;
//   final String contactNumber;
//   final List<Map<String, dynamic>> items;
//   final double totalAmount;
//   final double discount;
//   final double discountAmount;
//   final double netPayable;
//
//   const InvoicePreviewModal({
//     super.key,
//     required this.customerName,
//     required this.contactNumber,
//     required this.items,
//     required this.totalAmount,
//     required this.discount,
//     required this.discountAmount,
//     required this.netPayable,
//   });
//
//   static void show(
//     BuildContext context, {
//     required String customerName,
//     required String contactNumber,
//     required List<Map<String, dynamic>> items,
//     required double totalAmount,
//     required double discount,
//     required double discountAmount,
//     required double netPayable,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (_) => Padding(
//         padding: const EdgeInsets.only(
//           top: 16,
//           left: 16,
//           right: 16,
//           bottom: 32,
//         ),
//         child: InvoicePreviewModal(
//           customerName: customerName,
//           contactNumber: contactNumber,
//           items: items,
//           totalAmount: totalAmount,
//           discount: discount,
//           discountAmount: discountAmount,
//           netPayable: netPayable,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Invoice Preview",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           Text("Customer: $customerName"),
//           Text("Phone: $contactNumber"),
//           const SizedBox(height: 10),
//           const Divider(),
//           const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
//           ...items.map(
//             (item) => ListTile(
//               title: Text('${item['itemName']} (${item['category']})'),
//               subtitle: Text(
//                 'Qty: ${item['quantity']} | Unit: ${item['unitPrice']}',
//               ),
//               trailing: Text(
//                 'Subtotal: ${item['subTotal'].toStringAsFixed(2)}',
//               ),
//             ),
//           ),
//           const Divider(),
//           const SizedBox(height: 10),
//           _summaryRow("Total Amount", totalAmount),
//           _summaryRow("Discount (%)", discount),
//           _summaryRow("Discount Amount", discountAmount),
//           _summaryRow("Net Payable", netPayable, bold: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _summaryRow(String label, double value, {bool bold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value.toStringAsFixed(2),
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  Future<void> _printPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Invoice", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 10),
            pw.Text("Customer: $customerName"),
            pw.Text("Phone: $contactNumber"),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.Text("Items:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...items.map((item) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("${item['itemName']} (${item['category']})"),
                    pw.Text("Qty: ${item['quantity']}"),
                    pw.Text("Unit: ${item['unitPrice']}"),
                    pw.Text("Sub: ${item['subTotal'].toStringAsFixed(2)}"),
                  ],
                ),
              );
            }),
            pw.Divider(),
            pw.SizedBox(height: 10),
            _summaryRowPdf("Total", totalAmount),
            _summaryRowPdf("Discount (%)", discount),
            _summaryRowPdf("Discount Amount", discountAmount),
            _summaryRowPdf("Net Payable", netPayable, bold: true),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _summaryRowPdf(String label, double value, {bool bold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value.toStringAsFixed(2), style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Invoice Preview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Customer: $customerName"),
          Text("Phone: $contactNumber"),
          const SizedBox(height: 10),
          const Divider(),
          const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...items.map((item) => ListTile(
            title: Text('${item['itemName']} (${item['category']})'),
            subtitle: Text('Qty: ${item['quantity']} | Unit: ${item['unitPrice']}'),
            trailing: Text('Subtotal: ${item['subTotal'].toStringAsFixed(2)}'),
          )),
          const Divider(),
          const SizedBox(height: 10),
          _summaryRow("Total Amount", totalAmount),
          _summaryRow("Discount (%)", discount),
          _summaryRow("Discount Amount", discountAmount),
          _summaryRow("Net Payable", netPayable, bold: true),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _printPdf(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Print PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          )
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