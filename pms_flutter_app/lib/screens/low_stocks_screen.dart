import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/inventory.dart';

class LowStocksScreen extends StatefulWidget {
  const LowStocksScreen({super.key});

  @override
  State<LowStocksScreen> createState() => _LowStocksScreenState();
}

class _LowStocksScreenState extends State<LowStocksScreen> {
  List<Inventory> _lowStockMedicines = [];
  bool _isLoading = true;
  String _errorMessage = '';

   final String _baseUrl = 'http://192.168.0.186:8080/api/inventory/low-stock';
  //final String _baseUrl = 'http://192.168.0.197:8080/api/inventory/low-stock';

  @override
  void initState() {
    super.initState();
    _fetchLowStockItems();
  }

  Future<void> _fetchLowStockItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _lowStockMedicines =
              jsonList.map((json) => Inventory.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load low stock items: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade100,
      appBar: AppBar(
        title: const Text('Low Stock Medicines'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _lowStockMedicines.isEmpty
          ? const Center(child: Text('No low stock medicines found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _lowStockMedicines.length,
        itemBuilder: (context, index) {
          final medicine = _lowStockMedicines[index];
          return Card(
            color: Colors.red.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                medicine.itemName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company: ${medicine.companyName}',
                      style: const TextStyle(color: Colors.white)),
                  Text('Category: ${medicine.category}',
                      style: const TextStyle(color: Colors.white)),
                  Text('Generic: ${medicine.generic}',
                      style: const TextStyle(color: Colors.white)),
                  Text('Quantity: ${medicine.quantity}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}