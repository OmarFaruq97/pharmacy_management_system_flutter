// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../model/inventory.dart';
//
// class CreateInvoiceScreen extends StatefulWidget {
//   const CreateInvoiceScreen({super.key});
//
//   @override
//   State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
// }
//
// class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
//   final TextEditingController _customerNameController = TextEditingController();
//   final TextEditingController _contactNumberController =
//       TextEditingController();
//   final TextEditingController _itemNameController = TextEditingController();
//   final TextEditingController _categoryController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();
//   final TextEditingController _unitPriceController = TextEditingController();
//   final TextEditingController _discountController = TextEditingController();
//
//   double _amount = 0.0;
//   double _subTotal = 0.0;
//   double _discountAmount = 0.0;
//   double _netPayable = 0.0;
//
//   List<Inventory> _inventoryList = [];
//   Inventory? _selectedInventory;
//   bool _isLoadingInventory = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchInventory();
//     _quantityController.addListener(_calculateTotals);
//     _unitPriceController.addListener(_calculateTotals);
//     _discountController.addListener(_calculateTotals);
//   }
//
//   Future<void> _fetchInventory() async {
//     try {
//       final response = await http.get(
//         // Uri.parse('http://192.168.0.186:8080/api/inventory/all'),
//         Uri.parse('http://192.168.0.197:8080/api/inventory/all'),
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _inventoryList = data
//               .map((json) => Inventory.fromJson(json))
//               .toList();
//           _isLoadingInventory = false;
//         });
//       } else {
//         setState(() => _isLoadingInventory = false);
//       }
//     } catch (e) {
//       setState(() => _isLoadingInventory = false);
//     }
//   }
//
//   void _calculateTotals() {
//     setState(() {
//       final int quantity = int.tryParse(_quantityController.text) ?? 0;
//       final double unitPrice =
//           double.tryParse(_unitPriceController.text) ?? 0.0;
//       final double discount = double.tryParse(_discountController.text) ?? 0.0;
//       _amount = quantity * unitPrice;
//       _subTotal = _amount;
//       _discountAmount = _amount * (discount / 100);
//       _netPayable = _amount - _discountAmount;
//     });
//   }
//
//   Future<void> _submitInvoice() async {
//     if (_customerNameController.text.isEmpty ||
//         _contactNumberController.text.isEmpty ||
//         _itemNameController.text.isEmpty ||
//         _categoryController.text.isEmpty ||
//         _quantityController.text.isEmpty ||
//         _unitPriceController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill in all required fields.'),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//       return;
//     }
//
//     final invoiceData = [
//       {
//         "customerName": _customerNameController.text,
//         "contactNumber": _contactNumberController.text,
//         "itemName": _itemNameController.text,
//         "category": _categoryController.text,
//         "quantity": int.tryParse(_quantityController.text) ?? 0,
//         "unitPrice": double.tryParse(_unitPriceController.text) ?? 0.0,
//         "amount": _amount,
//         "subTotal": _subTotal,
//         "discount": double.tryParse(_discountController.text) ?? 0.0,
//         "discountAmount": _discountAmount,
//         "netPayable": _netPayable,
//       },
//     ];
//
//     final response = await http.post(
//       // Uri.parse('http://192.168.0.186:8080/api/invoice/create'),
//       Uri.parse('http://192.168.0.197:8080/api/invoice/create'),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(invoiceData),
//     );
//
//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Invoice created successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       _customerNameController.clear();
//       _contactNumberController.clear();
//       _itemNameController.clear();
//       _categoryController.clear();
//       _quantityController.clear();
//       _unitPriceController.clear();
//       _discountController.clear();
//       setState(() {
//         _amount = 0.0;
//         _subTotal = 0.0;
//         _discountAmount = 0.0;
//         _netPayable = 0.0;
//         _selectedInventory = null;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to create invoice (${response.statusCode})'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _customerNameController.dispose();
//     _contactNumberController.dispose();
//     _itemNameController.dispose();
//     _categoryController.dispose();
//     _quantityController.dispose();
//     _unitPriceController.dispose();
//     _discountController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.teal,
//       appBar: AppBar(
//         title: const Text('Create New Invoice'),
//         centerTitle: true,
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             _sectionHeader('Invoice Details'),
//             _buildTextField(_customerNameController, 'Customer Name'),
//             _buildTextField(
//               _contactNumberController,
//               'Contact Number',
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 30),
//             _sectionHeader('Item Details'),
//             _isLoadingInventory
//                 ? const CircularProgressIndicator()
//                 : DropdownButtonFormField<Inventory>(
//                     value: _selectedInventory,
//                     items: _inventoryList.map((inv) {
//                       return DropdownMenuItem(
//                         value: inv,
//                         child: Text('${inv.itemName} (${inv.category})'),
//                       );
//                     }).toList(),
//                     onChanged: (Inventory? newValue) {
//                       setState(() {
//                         _selectedInventory = newValue;
//                         _itemNameController.text = newValue?.itemName ?? '';
//                         _categoryController.text = newValue?.category ?? '';
//                         _unitPriceController.text =
//                             newValue?.sellPrice.toStringAsFixed(2) ?? '';
//                         _calculateTotals();
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Select Medicine',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//             _buildTextField(_categoryController, 'Category'),
//             _buildTextField(
//               _quantityController,
//               'Quantity',
//               keyboardType: TextInputType.number,
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             ),
//             _buildTextField(
//               _unitPriceController,
//               'Unit Price',
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//               ],
//             ),
//             _buildTextField(
//               _discountController,
//               'Discount (%)',
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//               ],
//             ),
//             const SizedBox(height: 30),
//             _sectionHeader('Summary'),
//             _buildSummaryRow('Amount:', _amount),
//             _buildSummaryRow('Sub Total:', _subTotal),
//             _buildSummaryRow('Discount Amount:', _discountAmount),
//             _buildSummaryRow('Net Payable:', _netPayable, isBold: true),
//             const SizedBox(height: 30),
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: _submitInvoice,
//                 icon: const Icon(Icons.check_circle_outline),
//                 label: const Text('Create Invoice'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).colorScheme.secondary,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 40,
//                     vertical: 15,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   textStyle: const TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _sectionHeader(String text) => Text(
//     text,
//     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//       fontWeight: FontWeight.bold,
//       color: Theme.of(context).colorScheme.primary,
//     ),
//   );
//
//   Widget _buildTextField(
//     TextEditingController controller,
//     String labelText, {
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         decoration: InputDecoration(
//           labelText: labelText,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           filled: true,
//           fillColor: Colors.grey[50],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: isBold
//                   ? Theme.of(context).colorScheme.primary
//                   : Colors.black87,
//             ),
//           ),
//           Text(
//             value.toStringAsFixed(2),
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: isBold
//                   ? Theme.of(context).colorScheme.primary
//                   : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
    final url = Uri.parse('http://192.168.0.197:8080/api/inventory/all');
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

    final url = Uri.parse('http://192.168.0.197:8080/api/invoice/create');
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
