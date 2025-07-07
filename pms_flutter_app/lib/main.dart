import 'package:flutter/material.dart';
import 'package:pms_flutter_app/screens/add_medicine_screen.dart';
import 'package:pms_flutter_app/screens/create_invoice.dart';
import 'package:pms_flutter_app/screens/inventory_screen.dart';
import 'package:pms_flutter_app/screens/invoice_history_screen.dart';
import 'package:pms_flutter_app/screens/low_stocks_screen.dart';

void main() {
  runApp(const PmsApp());
}

class PmsApp extends StatelessWidget {
  const PmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pharmacy Management System'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_pharmacy,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to Pharmacy Management System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildHomeButton(context, Icons.inventory, 'Inventory'),
                  _buildHomeButton(context, Icons.add_box, 'Add-Medicine'),
                  _buildHomeButton(
                    context,
                    Icons.receipt_long,
                    'Create-Invoices',
                  ),
                  _buildHomeButton(context, Icons.history, 'Invoice-History'),
                  _buildHomeButton(context, Icons.person, 'Users'),
                  _buildHomeButton(context, Icons.warning_amber, 'Low-Stocks'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context, IconData icon, String label) {
    return SizedBox(
      width: 120,
      height: 120,
      child: ElevatedButton(
        onPressed: () {
          switch (label) {
            case 'Inventory':
              // Navigate to InventoryScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryScreen(),
                ),
              );
              break;
            case 'Add-Medicine':
              // Navigate to AddMedicineScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMedicineScreen(),
                ),
              );
              break;
            case 'Create-Invoices':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateInvoiceScreen(),
                ),
              );
              break;
            case 'Invoice-History':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvoiceHistoryScreen(),
                ),
              );
              break;
            case 'Users':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vai Coming Soon: Users')),
              );
              break;
            case 'Low-Stocks':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LowStocksScreen(),
                ),
              );
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unknown Action for: $label')),
              );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          foregroundColor: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
