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
  final TextEditingController _discountController = TextEditingController();

  List<Inventory> _inventoryList = [];
  bool _isLoadingInventory = true;

  List<Map<String, dynamic>> _invoiceItems = [];

  @override
  void initState() {
    super.initState();
    _fetchInventory();

    _discountController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _fetchInventory() async {
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

  void _addInvoiceItem(Inventory inventory, String qtyStr) {
    final int quantity = int.tryParse(qtyStr) ?? 0;
    final double unitPrice = inventory.sellPrice;
    final double subTotal = quantity * unitPrice;

    setState(() {
      _invoiceItems.add({
        "itemName": inventory.itemName,
        "category": inventory.category,
        "quantity": quantity,
        "unitPrice": unitPrice,
        "subTotal": subTotal,
      });
    });
  }

  void _removeInvoiceItem(int index) {
    setState(() {
      _invoiceItems.removeAt(index);
    });
  }

  double get totalAmount =>
      _invoiceItems.fold(0.0, (sum, item) => sum + (item['subTotal'] ?? 0.0));

  double get discountPercent =>
      double.tryParse(_discountController.text) ?? 0.0;

  double get discountAmount => totalAmount * (discountPercent / 100);

  double get netPayable => totalAmount - discountAmount;

  Future<void> _submitInvoice() async {
    if (_invoiceItems.isEmpty ||
        _customerNameController.text.isEmpty ||
        _contactNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill customer info & add at least one item.'),
        ),
      );
      return;
    }

    final payload = _invoiceItems.map((item) {
      return {
        "customerName": _customerNameController.text,
        "contactNumber": _contactNumberController.text,
        "discount": discountPercent,
        "discountAmount": discountAmount,
        "netPayable": netPayable,
        ...item,
      };
    }).toList();

    final url = Uri.parse('http://192.168.0.186:8080/api/invoice/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
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
    _discountController.clear();
    setState(() => _invoiceItems.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
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
                  _sectionTitle("Customer Info"),
                  _buildTextField(_customerNameController, "Customer Name"),
                  _buildTextField(
                    _contactNumberController,
                    "Phone Number",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle("Medicine List"),
                  MedicineItemForm(
                    inventoryList: _inventoryList,
                    onAdd: _addInvoiceItem,
                  ),

                  const SizedBox(height: 10),
                  ..._invoiceItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(
                          '${item['itemName']} (${item['category']})',
                        ),
                        subtitle: Text(
                          'Qty: ${item['quantity']} | Unit price:${item['unitPrice']} |Subtotal: ${item['subTotal'].toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeInvoiceItem(index),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),
                  _sectionTitle("Summary"),
                  _buildTextField(
                    _discountController,
                    "Discount %",
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 10),
                  _summaryRow("Total Amount", totalAmount),
                  _summaryRow("Discount Amount", discountAmount),
                  _summaryRow("Net Payable", netPayable, bold: true),

                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _submitInvoice,
                      icon: const Icon(Icons.save),
                      label: const Text('Submit Invoice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

class MedicineItemForm extends StatefulWidget {
  final List<Inventory> inventoryList;
  final Function(Inventory, String) onAdd;

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
            Expanded(child: _buildNumberField(_quantityController, 'Quantity')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (selectedInventory != null &&
                    _quantityController.text.isNotEmpty) {
                  widget.onAdd(selectedInventory!, _quantityController.text);
                  _quantityController.clear();
                  setState(() => selectedInventory = null);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
