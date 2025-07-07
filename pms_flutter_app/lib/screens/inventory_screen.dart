import 'package:flutter/material.dart';
import '../model/inventory.dart';
import '../services/inventory_service.dart';
import 'add_medicine_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Inventory> _medicines = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  final InventoryService _inventoryService = InventoryService();

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _inventoryService.fetchAllMedicines();
      setState(() {
        _medicines = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchMedicines(String query) async {
    if (query.isEmpty) {
      _fetchMedicines();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _inventoryService.searchMedicines(query);
      setState(() {
        _medicines = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchMedicines,
              decoration: InputDecoration(
                hintText: 'Search by medicine name...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _fetchMedicines,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _medicines.isEmpty
          ? const Center(child: Text('No medicines found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _medicines.length,
              itemBuilder: (context, index) {
                final medicine = _medicines[index];
                return Card(
                  color: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      medicine.itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company: ${medicine.companyName}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Category: ${medicine.category}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Generic: ${medicine.generic}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Quantity: ${medicine.quantity}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Sales Unit price: ${medicine.unitPrice}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
          );
          if (result == true) {
            _fetchMedicines();
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
