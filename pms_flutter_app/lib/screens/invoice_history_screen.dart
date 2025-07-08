import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/invoice_history.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  List<InvoiceHistory> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.186:8080/api/invoice/all'),
         //Uri.parse('http://192.168.0.197:8080/api/invoice/all'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _invoices = data
              .map((json) => InvoiceHistory.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        throw Exception('Failed to load invoices');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching invoices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice History'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
          ? const Center(child: Text('No invoices found.'))
          : ListView.builder(
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final invoice = _invoices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      'Invoice: ${invoice.invoiceNumber ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${invoice.customerName}'),
                        Text(
                          'Medicine: ${invoice.itemName} (${invoice.category})',
                        ),
                        Text('Qty: ${invoice.quantity} Pisces'),
                        Text('Unit Price: ${invoice.unitPrice}'),
                        Text('Amount: ${invoice.amount}'),
                        Text('Discount Amount: ${invoice.discountAmount} TAKA'),
                        Text(
                          'Net Payable: ${invoice.netPayable.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}