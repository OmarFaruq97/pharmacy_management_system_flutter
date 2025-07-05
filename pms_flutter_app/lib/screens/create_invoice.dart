import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../model/inventory.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  List<Inventory> _inventoryList = [];
  bool _isLoadingInventory = true;

  List<Map<String, dynamic>> _invoiceItems = [];

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    // final url = Uri.parse('http://192.168.0.197:8080/api/inventory/all');
    final url = Uri.parse('http://192.168.0.186:8080/api/inventory/all');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _inventoryList = data
              .map((json) => Inventory.fromJson(json))
              .toList();
          _isLoadingInventory = false;
        });
      } else {
        setState(() => _isLoadingInventory = false);
      }
    } catch (e) {
      setState(() => _isLoadingInventory = false);
    }
  }

  void _addInvoiceItem(
    Inventory inventory,
    String quantityStr,
    String discountStr,
  ) {
    final int quantity = int.tryParse(quantityStr) ?? 0;
    final double unitPrice = inventory.sellPrice;
    final double amount = quantity * unitPrice;
    final double discount = double.tryParse(discountStr) ?? 0;
    final double discountAmount = amount * (discount / 100);
    final double netPayable = amount - discountAmount;

    setState(() {
      _invoiceItems.add({
        "itemName": inventory.itemName,
        "category": inventory.category,
        "quantity": quantity,
        "unitPrice": unitPrice,
        "amount": amount,
        "subTotal": amount,
        "discount": discount,
        "discountAmount": discountAmount,
        "netPayable": netPayable,
      });
    });
  }

  Future<void> _submitInvoice() async {
    if (_invoiceItems.isEmpty ||
        _customerNameController.text.isEmpty ||
        _contactNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill customer info & add at least one item!'),
        ),
      );
      return;
    }

    final List<Map<String, dynamic>> invoicePayload = _invoiceItems.map((item) {
      return {
        "customerName": _customerNameController.text,
        "contactNumber": _contactNumberController.text,
        ...item,
      };
    }).toList();

    // final url = Uri.parse('http://192.168.0.197:8080/api/invoice/create');
    final url = Uri.parse('http://192.168.0.186:8080/api/invoice/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(invoicePayload),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create invoice (${response.statusCode})'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _customerNameController.clear();
    _contactNumberController.clear();
    setState(() => _invoiceItems.clear());
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _isLoadingInventory
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer Info",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildTextField(_customerNameController, "Customer Name"),
                  _buildTextField(
                    _contactNumberController,
                    "Contact Number",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Add Medicine",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  MedicineItemForm(
                    inventoryList: _inventoryList,
                    onAdd: _addInvoiceItem,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Invoice Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ..._invoiceItems.map(
                    (item) => ListTile(
                      title: Text('${item['itemName']} (${item['category']})'),
                      subtitle: Text(
                        'Qty: ${item['quantity']} | Total: ${item['netPayable'].toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _submitInvoice,
                      icon: const Icon(Icons.save),
                      label: const Text('Submit Invoice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}

class MedicineItemForm extends StatefulWidget {
  final List<Inventory> inventoryList;
  final Function(Inventory, String, String) onAdd;

  const MedicineItemForm({
    super.key,
    required this.inventoryList,
    required this.onAdd,
  });

  @override
  State<MedicineItemForm> createState() => _MedicineItemFormState();
}

class _MedicineItemFormState extends State<MedicineItemForm> {
  Inventory? selectedInventory;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<Inventory>(
          value: selectedInventory,
          hint: const Text('Select Medicine'),
          items: widget.inventoryList.map((inv) {
            return DropdownMenuItem(
              value: inv,
              child: Text('${inv.itemName} (${inv.category})'),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedInventory = value),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildNumberField(_quantityController, 'Qty')),
            const SizedBox(width: 10),
            Expanded(
              child: _buildNumberField(_discountController, 'Discount %'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                if (selectedInventory != null) {
                  widget.onAdd(
                    selectedInventory!,
                    _quantityController.text,
                    _discountController.text,
                  );
                  _quantityController.clear();
                  _discountController.clear();
                  setState(() => selectedInventory = null);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
