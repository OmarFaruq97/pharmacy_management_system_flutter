import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pms_flutter_app/screens/add_medicine_screen.dart'; // Import your AddMedicineScreen


import '../model/inventory.dart'; // Import the Inventory model

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Inventory> _medicines = []; // List to hold fetched medicines
  bool _isLoading = true; // State to manage loading indicator
  String _errorMessage = ''; // State to hold error messages

  // Base URL for your Spring Boot backend API.
  // IMPORTANT: Adjust this based on your backend's actual IP/port.
  // For Android Emulator to access localhost: 'http://10.0.2.2:8080'
  // For physical device/iOS simulator: 'http://YOUR_MACHINE_IP:8080'
  final String _baseUrl = 'http://192.168.0.197:8080/api/inventory'; // Assuming endpoint for all inventory items

  @override
  void initState() {
    super.initState();
    _fetchMedicines(); // Fetch medicines when the screen initializes
  }

  // Method to fetch medicines from the Spring Boot backend
  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true; // Show loading indicator
      _errorMessage = ''; // Clear previous errors
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/all')); // Calling the /api/inventory/all endpoint
      // You might need to add JWT token if your API is secured:
      // headers: {'Authorization': 'Bearer YOUR_JWT_TOKEN'}

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON.
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _medicines = jsonList.map((json) => Inventory.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception or set an error message.
        setState(() {
          _errorMessage = 'Failed to load medicines: ${response.statusCode}';
          _isLoading = false;
        });
        print('Failed to load medicines. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Catch any network errors or other exceptions
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
      print('Error fetching medicines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchMedicines, // Retry button
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _medicines.isEmpty
          ? const Center(child: Text('No medicines found in inventory.')) // No data message
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
                  Text('Unit Price: \$${medicine.unitPrice.toStringAsFixed(2)}'),
                  Text('Sell Price: \$${medicine.sellPrice.toStringAsFixed(2)}'),
                  if (medicine.receivedDate != null)
                    Text('Received: ${medicine.receivedDate}'),
                  // Add more details as needed
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddMedicineScreen and refresh inventory when it's popped
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
          );
          if (result == true) { // Assuming AddMedicineScreen returns true on successful add
            _fetchMedicines(); // Refresh the list
          }
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Add New Medicine',
      ),
    );
  }
}
