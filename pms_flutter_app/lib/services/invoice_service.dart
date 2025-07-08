import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/inventory.dart';

class InvoiceService {
  // static const String baseUrl = 'http://192.168.0.186:8080/api';
  static const String baseUrl = 'http://192.168.0.197:8080/api';

  Future<List<Inventory>> searchMedicines(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/inventory/search?name=$query'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Inventory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search medicines');
    }
  }

  Future<bool> submitInvoice(List<Map<String, dynamic>> invoiceItems) async {
    final url = Uri.parse('$baseUrl/invoice/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(invoiceItems),
    );
    return response.statusCode == 200;
  }
}
