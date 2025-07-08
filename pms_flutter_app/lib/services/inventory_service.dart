import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/inventory.dart';

class InventoryService {
   static const String _baseUrl = "http://192.168.0.186:8080/api/inventory";
  //static const String _baseUrl = "http://192.168.0.197:8080/api/inventory";

  Future<List<Inventory>> fetchAllMedicines() async {
    final response = await http.get(Uri.parse("$_baseUrl/all"));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch medicines');
    }
  }

  Future<List<Inventory>> searchMedicines(String name) async {
    final response = await http.get(Uri.parse("$_baseUrl/search?name=$name"));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Search failed');
    }
  }

  Future<bool> submitMedicine(Map<String, dynamic> medicineData) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/receive"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(medicineData),
    );
    return response.statusCode == 200;
  }
}
