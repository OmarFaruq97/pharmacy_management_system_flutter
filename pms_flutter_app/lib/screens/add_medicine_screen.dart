import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all form fields
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _genericController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _purchaseDiscountController =
      TextEditingController(); // Now optional
  final TextEditingController _sellPriceController = TextEditingController();

  DateTime _receivedDate = DateTime.now();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final int quantity = int.parse(_quantityController.text);
      final double unitPrice = double.parse(_unitPriceController.text);

      // CHANGED: Handle empty discount field (now optional)
      final double discount = _purchaseDiscountController.text.isEmpty
          ? 0.0 // Default to 0 if empty
          : double.parse(_purchaseDiscountController.text);

      final double netPurchasePrice = unitPrice - discount;
      final double sellPrice = double.parse(_sellPriceController.text);
      final double totalValue = netPurchasePrice * quantity;

      final Map<String, dynamic> medicineData = {
        "companyName": _companyNameController.text,
        "itemName": _itemNameController.text,
        "category": _categoryController.text,
        "generic": _genericController.text,
        "quantity": quantity,
        "unitPrice": unitPrice,
        "purchaseDiscount": discount, // Will be 0.0 if empty
        "netPurchasePrice": netPurchasePrice,
        "sellPrice": sellPrice,
        "totalInventoryValue": totalValue,
        "receivedDate": _receivedDate.toIso8601String(),
      };

      const String apiUrl = "http://192.168.0.186:8080/api/inventory/receive";
      // const String apiUrl = "http://192.168.0.197:8080/api/inventory/receive";

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(medicineData),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medicine added successfully')),
          );
          _formKey.currentState!.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add medicine: ${response.statusCode}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _receivedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _receivedDate) {
      setState(() {
        _receivedDate = picked;
      });
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isDecimal = false,
    bool isNumber = false,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : isNumber
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: isRequired ? null : 'Optional',
          // Show hint for optional fields
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          // Only validate if field is required
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text('Add Medicine'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(_companyNameController, 'Company Name'),
            _buildTextField(_itemNameController, 'Item Name'),
            _buildTextField(_categoryController, 'Category'),
            _buildTextField(_genericController, 'Generic'),
            _buildTextField(_quantityController, 'Quantity', isNumber: true),
            _buildTextField(
              _unitPriceController,
              'Unit Price',
              isDecimal: true,
            ),
            // CHANGED: Made purchase discount optional
            _buildTextField(
              _purchaseDiscountController,
              'Purchase Discount',
              isDecimal: true,
              isRequired: false, // This makes the field optional
            ),
            _buildTextField(
              _sellPriceController,
              'Sell Price',
              isDecimal: true,
            ),
            ListTile(
              title: Text(
                "Received Date: ${_receivedDate.toLocal()}".split(' ')[0],
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Add to Inventory'),
            ),
          ],
        ),
      ),
    );
  }
}
