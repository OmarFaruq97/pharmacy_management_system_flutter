import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pms_flutter_app/screens/add_medicine_screen.dart';
import '../model/inventory.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Inventory> _medicines = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // final String _baseUrl = 'http://192.168.0.197:8080/api/inventory';
  final String _baseUrl = 'http://192.168.0.186:8080/api/inventory';

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/all'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _medicines = jsonList
              .map((json) => Inventory.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load medicines: ${response.statusCode}';
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

  Future<void> _deleteMedicine(String name, String category) async {
    final response = await http.delete(
      Uri.parse(
        '$_baseUrl/delete-by-name-and-category?name=$name&category=$category',
      ),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchMedicines();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUpdateDialog(Inventory medicine) {
    final TextEditingController priceController = TextEditingController(
      text: medicine.sellPrice.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Sell Price'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'New Sell Price'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null) {
                final response = await http.put(
                  Uri.parse(
                    '$_baseUrl/update-by-name-and-category?name=${medicine.itemName}&category=${medicine.category}',
                  ),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'itemName': medicine.itemName,
                    'category': medicine.category,
                    'sellPrice': newPrice,
                  }),
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                  _fetchMedicines();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update failed: ${response.body}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _fetchMedicines,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _medicines.isEmpty
          ? const Center(child: Text('No medicines found in inventory.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _medicines.length,
              itemBuilder: (context, index) {
                final medicine = _medicines[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.itemName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Company: ${medicine.companyName}'),
                        Text('Category: ${medicine.category}'),
                        Text('Generic: ${medicine.generic}'),
                        Text('Quantity: ${medicine.quantity}'),
                        Text(
                          'Unit Price: ${medicine.unitPrice.toStringAsFixed(2)}',
                        ),
                        Text(
                          'Sell Price: ${medicine.sellPrice.toStringAsFixed(2)}',
                        ),
                        if (medicine.receivedDate != null)
                          Text('Received: ${medicine.receivedDate}'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_attributes,
                                color: Colors.orange,
                              ),
                              onPressed: () => _showUpdateDialog(medicine),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_forever_outlined,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteMedicine(
                                medicine.itemName,
                                medicine.category,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
          );
          if (result == true) {
            _fetchMedicines();
          }
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        tooltip: 'Add New Medicine',
        child: const Icon(Icons.add),
      ),
    );
  }
}
