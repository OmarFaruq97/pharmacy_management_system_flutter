// ✅ Full Updated CreateInvoiceScreen with separated API service and medicine search box

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../modals/invoice_preview_modal.dart';
import '../model/inventory.dart';
import '../services/invoice_service.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  final InvoiceService _invoiceService = InvoiceService();

  List<Map<String, dynamic>> _invoiceItems = [];

  @override
  void initState() {
    super.initState();
    _discountController.addListener(() => setState(() {}));
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
    setState(() => _invoiceItems.removeAt(index));
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
        const SnackBar(content: Text('Fill customer info & add items.')),
      );
      return;
    }

    final payload = _invoiceItems
        .map(
          (item) => {
        "customerName": _customerNameController.text,
        "contactNumber": _contactNumberController.text,
        "discount": discountPercent,
        "discountAmount": discountAmount,
        "netPayable": netPayable,
        ...item,
      },
    )
        .toList();

    final success = await _invoiceService.submitInvoice(payload);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice created'), backgroundColor: Colors.green),
      );
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create invoice'), backgroundColor: Colors.red),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Customer Info"),
            _buildTextField(_customerNameController, "Customer Name"),
            _buildTextField(_contactNumberController, "Phone Number", keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _sectionTitle("Medicine List"),
            MedicineItemForm(onAdd: _addInvoiceItem),
            const SizedBox(height: 10),
            ..._invoiceItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text('${item['itemName']} (${item['category']})'),
                  subtitle: Text(
                    'Qty: ${item['quantity']} | Unit: ${item['unitPrice']} | Subtotal: ${item['subTotal'].toStringAsFixed(2)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeInvoiceItem(index),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            _sectionTitle("Summary"),
            _buildTextField(_discountController, "Discount %", keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 10),
            _summaryRow("Total Amount", totalAmount),
            _summaryRow("Discount Amount", discountAmount),
            _summaryRow("Net Payable", netPayable, bold: true),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    InvoicePreviewModal.show(
                      context,
                      customerName: _customerNameController.text,
                      contactNumber: _contactNumberController.text,
                      items: _invoiceItems,
                      totalAmount: totalAmount,
                      discount: discountPercent,
                      discountAmount: discountAmount,
                      netPayable: netPayable,
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Preview'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _submitInvoice,
                  icon: const Icon(Icons.save),
                  label: const Text('Submit Invoice'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
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
          Text(label, style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value.toStringAsFixed(2), style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class MedicineItemForm extends StatefulWidget {
  final Function(Inventory, String) onAdd;

  const MedicineItemForm({super.key, required this.onAdd});

  @override
  State<MedicineItemForm> createState() => _MedicineItemFormState();
}

class _MedicineItemFormState extends State<MedicineItemForm> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final InvoiceService _service = InvoiceService();
  Inventory? selectedInventory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TypeAheadFormField<Inventory>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search Medicine',
              border: OutlineInputBorder(),
            ),
          ),
          suggestionsCallback: _service.searchMedicines,
          itemBuilder: (context, Inventory suggestion) {
            return ListTile(
              title: Text('${suggestion.itemName} (${suggestion.category})'),
            );
          },
          onSuggestionSelected: (Inventory suggestion) {
            setState(() {
              selectedInventory = suggestion;
              _searchController.text = '${suggestion.itemName} (${suggestion.category})';
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildNumberField(_quantityController, 'Quantity')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (selectedInventory != null && _quantityController.text.isNotEmpty) {
                  widget.onAdd(selectedInventory!, _quantityController.text);
                  _quantityController.clear();
                  _searchController.clear();
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
