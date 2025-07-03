// create_invoice.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  double _amount = 0.0;
  double _subTotal = 0.0;
  double _discountAmount = 0.0;
  double _netPayable = 0.0;

  List<Inventory> _inventoryList = [];
  Inventory? _selectedInventory;
  bool _isLoadingInventory = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
    _quantityController.addListener(_calculateTotals);
    _unitPriceController.addListener(_calculateTotals);
    _discountController.addListener(_calculateTotals);
  }

  Future<void> _fetchInventory() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.197:8080/api/inventory/all'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _inventoryList = data
              .map((json) => Inventory.fromJson(json))
              .toList();
          _isLoadingInventory = false;
        });
      } else {
        setState(() {
          _isLoadingInventory = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingInventory = false;
      });
    }
  }

  void _calculateTotals() {
    setState(() {
      final int quantity = int.tryParse(_quantityController.text) ?? 0;
      final double unitPrice =
          double.tryParse(_unitPriceController.text) ?? 0.0;
      final double discount = double.tryParse(_discountController.text) ?? 0.0;
      _amount = quantity * unitPrice;
      _subTotal = _amount;
      _discountAmount = _amount * (discount / 100);
      _netPayable = _amount - _discountAmount;
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _contactNumberController.dispose();
    _itemNameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Invoice'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _customerNameController,
              labelText: 'Customer Name',
            ),
            _buildTextField(
              controller: _contactNumberController,
              labelText: 'Contact Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),

            Text(
              'Item Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 15),

            _isLoadingInventory
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<Inventory>(
                    value: _selectedInventory,
                    items: _inventoryList.map((inv) {
                      return DropdownMenuItem(
                        value: inv,
                        child: Text('${inv.itemName} (${inv.category})'),
                      );
                    }).toList(),
                    onChanged: (Inventory? newValue) {
                      setState(() {
                        _selectedInventory = newValue;
                        _itemNameController.text = newValue?.itemName ?? '';
                        _categoryController.text = newValue?.category ?? '';
                        _unitPriceController.text =
                            newValue?.sellPrice.toStringAsFixed(2) ?? '';
                        _calculateTotals();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Medicine',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

            const SizedBox(height: 10),
            _buildTextField(
              controller: _categoryController,
              labelText: 'Category',
            ),
            _buildTextField(
              controller: _quantityController,
              labelText: 'Quantity',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildTextField(
              controller: _unitPriceController,
              labelText: 'Unit Price',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            _buildTextField(
              controller: _discountController,
              labelText: 'Discount (%)',
              hintText: 'e.g., 5',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 30),

            Text(
              'Summary',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 15),
            _buildSummaryRow('Amount:', _amount),
            _buildSummaryRow('Sub Total:', _subTotal),
            _buildSummaryRow('Discount Amount:', _discountAmount),
            _buildSummaryRow('Net Payable:', _netPayable, isBold: true),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Create Invoice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black87,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
