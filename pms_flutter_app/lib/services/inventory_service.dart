// services/inventory_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class InventoryService {
  static const String _apiUrl =
      "http://192.168.0.186:8080/api/inventory/receive";

  Future<bool> submitMedicine(Map<String, dynamic> medicineData) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(medicineData),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error submitting medicine: $e");
    }
  }
}
