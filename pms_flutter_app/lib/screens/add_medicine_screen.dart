import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // For making HTTP requests to your backend
import 'dart:convert'; // For encoding/decoding JSON data

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  // GlobalKey for the Form widget, used for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for capturing user input from TextFormFields
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _strengthController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();

  // Variables to hold the selected values from the dropdowns
  String? _selectedCategory;
  String? _selectedGeneric;

  // Example lists for dropdowns.
  // In a real application, these lists would typically be fetched dynamically
  // from your Spring Boot backend (e.g., via a separate API call when the screen loads).
  final List<String> _categories = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Cream',
    'Ointment',
    'Suspension',
  ];
  final List<String> _generics = [
    'Paracetamol',
    'Omeprazole',
    'Amoxicillin',
    'Cetirizine',
    'Metformin',
    'Ibuprofen',
    'Amlodipine',
  ];

  // Base URL for your Spring Boot backend API.
  // IMPORTANT:
  // - If running on an Android Emulator, 'http://10.0.2.2:8080' points to your machine's localhost.
  // - If running on a physical Android device or iOS simulator/device, replace '10.0.2.2'
  //   with your actual machine's IP address (e.g., 'http://192.168.1.5:8080').
  // - Ensure your Spring Boot application is running and accessible at this address.
  final String _baseUrl =
      'http://10.0.2.2:8080/api/medicines'; // Assuming this is your endpoint for adding medicines

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks when the widget is removed
    _medicineNameController.dispose();
    _strengthController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  // Asynchronous method to handle adding medicine by sending data to the backend
  Future<void> _addMedicine() async {
    // Validate all fields in the form
    if (_formKey.currentState!.validate()) {
      // Ensure dropdowns have selections
      if (_selectedCategory == null || _selectedGeneric == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both Category and Generic.'),
          ),
        );
        return; // Stop execution if dropdowns are not selected
      }

      // Prepare the medicine data as a Map, matching your Spring Boot DTO/Entity structure
      final medicineData = {
        'name': _medicineNameController.text.trim(),
        // .trim() removes leading/trailing whitespace
        'category': _selectedCategory,
        'generic': _selectedGeneric,
        'strength': _strengthController.text.trim(),
        'quantity': int.tryParse(_quantityController.text.trim()) ?? 0,
        // Safely parse to int, default to 0 if invalid
        'unitPrice': double.tryParse(_unitPriceController.text.trim()) ?? 0.0,
        // Safely parse to double, default to 0.0 if invalid
        // You might need to add other fields here based on your Spring Boot Medicine entity,
        // for example: 'company', 'batchNumber', 'expiryDate'.
        // Example: 'company': 'XYZ Pharma', 'batchNumber': 'B12345', 'expiryDate': '2026-12-31'
      };

      print('Sending Medicine Data: $medicineData'); // Log the data being sent

      try {
        // Send a POST request to your Spring Boot API
        final response = await http.post(
          Uri.parse(_baseUrl), // Convert the URL string to a Uri object
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            // Specify JSON content type
            // If your API requires authentication (e.g., JWT), add the Authorization header:
            // 'Authorization': 'Bearer YOUR_JWT_TOKEN_HERE', // Replace with your actual JWT token
          },
          body: jsonEncode(
            medicineData,
          ), // Encode the Dart Map to a JSON string
        );

        // Check the HTTP status code of the response
        if (response.statusCode == 201 || response.statusCode == 200) {
          // Success: Medicine added successfully
          print('Medicine added successfully: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medicine added successfully!')),
          );
          // Clear the form fields and reset dropdowns after successful submission
          _medicineNameController.clear();
          _strengthController.clear();
          _quantityController.clear();
          _unitPriceController.clear();
          setState(() {
            _selectedCategory = null;
            _selectedGeneric = null;
          });
        } else {
          // Error: API returned a non-success status code
          print('Failed to add medicine. Status code: ${response.statusCode}');
          print(
            'Response body: ${response.body}',
          ); // Print the error response from backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add medicine: ${response.body}')),
          );
        }
      } catch (e) {
        // Catch any network or other exceptions
        print('Error sending data to backend: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error connecting to server. Please check your network and server status.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Use your desired AppBar color
        foregroundColor:
            Colors.white, // Color for the title text and icons in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the entire form
        child: Form(
          key: _formKey, // Associate the GlobalKey with the Form
          child: ListView(
            // Use ListView to make the form scrollable if content overflows
            children: [
              // Medicine Name Text Field
              _buildTextField(_medicineNameController, 'Medicine Name'),

              // Category Dropdown
              _buildDropdownField('Category', _selectedCategory, _categories, (
                newValue,
              ) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }),

              // Generic Dropdown
              _buildDropdownField('Generic', _selectedGeneric, _generics, (
                newValue,
              ) {
                setState(() {
                  _selectedGeneric = newValue;
                });
              }),

              // Strength Text Field
              _buildTextField(_strengthController, 'Strength'),

              // Quantity Text Field (numeric input)
              _buildTextField(_quantityController, 'Quantity', isNumber: true),

              // Unit Price Text Field (numeric input)
              _buildTextField(
                _unitPriceController,
                'Unit Price',
                isNumber: true,
              ),

              const SizedBox(height: 20), // Spacer
              // Add Medicine Button
              ElevatedButton(
                onPressed: _addMedicine,
                // Call the method to handle form submission and API call
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  // Button background color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  // Vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Rounded corners for the button
                  ),
                ),
                child: const Text(
                  'Add Medicine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ), // Text style for the button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable widget to create a TextFormField with common styling and validation
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      // Padding below each text field
      child: TextFormField(
        controller: controller,
        // Set keyboard type based on whether it's a number field
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label, // Label for the input field
          border: const OutlineInputBorder(), // Outline border style
          filled: true, // Enable fill color
          fillColor:
              Colors.grey[50], // Light grey background for the input area
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label'; // Validation for empty fields
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Please enter a valid number'; // Validation for numeric fields
          }
          return null; // Return null if validation passes
        },
      ),
    );
  }

  // Reusable widget to create a DropdownButtonFormField with common styling and validation
  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      // Padding below each dropdown field
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        // Currently selected value
        hint: Text('Select $label'),
        // Hint text when no item is selected
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        // Callback when a new item is selected
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $label'; // Validation for dropdown selection
          }
          return null;
        },
      ),
    );
  }
}
