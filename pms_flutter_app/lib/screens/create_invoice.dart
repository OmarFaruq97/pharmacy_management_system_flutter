import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  // Controllers for text input fields

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  // State variables for calculated values
  double _amount = 0.0;
  double _subTotal = 0.0;
  double _discountAmount = 0.0;
  double _netPayable = 0.0;

  @override
  void initState() {
    super.initState();
    // Add listeners to text controllers to recalculate totals on change
    _quantityController.addListener(_calculateTotals);
    _unitPriceController.addListener(_calculateTotals);
    _discountController.addListener(_calculateTotals);
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources

    _customerNameController.dispose();
    _contactNumberController.dispose();
    _itemNameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  // Function to calculate amount, sub-total, discount amount, and net payable
  void _calculateTotals() {
    setState(() {
      final int quantity = int.tryParse(_quantityController.text) ?? 0;
      final double unitPrice =
          double.tryParse(_unitPriceController.text) ?? 0.0;
      final double discount = double.tryParse(_discountController.text) ?? 0.0;

      // Calculate amount (price before discount for this item)
      _amount = quantity * unitPrice;

      // For a single item invoice, subTotal is the same as amount
      _subTotal = _amount;

      // Calculate discount amount
      _discountAmount = _amount * (discount / 100);

      // Calculate net payable
      _netPayable = _amount - _discountAmount;
    });
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
            // Invoice Details Section
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
              hintText: 'e.g., John Doe',
              keyboardType: TextInputType.text,
            ),
            _buildTextField(
              controller: _contactNumberController,
              labelText: 'Contact Number',
              hintText: 'e.g., +1234567890',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),

            // Item Details Section
            Text(
              'Item Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _itemNameController,
              labelText: 'Item Name',

              keyboardType: TextInputType.text,
            ),
            _buildTextField(
              controller: _categoryController,
              labelText: 'Category',
              keyboardType: TextInputType.text,
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
              hintText: 'e.g., 5 (for 5%)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 30),

            // Calculated Totals Section
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

            // Create Invoice Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Basic validation
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

  // Helper widget to build text input fields
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  // Helper widget to display summary rows
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
            value.toStringAsFixed(2), // Format to 2 decimal places
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
