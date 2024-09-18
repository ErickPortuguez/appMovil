import 'package:flutter/material.dart';
import 'package:myapp/models/supplier_model.dart';
import 'package:myapp/services/supplier_service.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SupplierListScreenState createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  List<Supplier> _suppliers = [];
  List<Supplier> _filteredSuppliers = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final suppliers = await ApiServiceSupplier.getActiveSuppliers();
      setState(() {
        _suppliers = suppliers;
        _filteredSuppliers = suppliers;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los supplieres: $e'),
        ),
      );
    }
  }

  void _filterSuppliers(String query) {
    setState(() {
      _filteredSuppliers = _suppliers
          .where((supplier) =>
              supplier.names.toLowerCase().contains(query.toLowerCase()) ||
              supplier.lastName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Lista de Proveedores',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16), // Espacio agregado encima del TextField
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar vendedores',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterSuppliers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSuppliers.length,
              itemBuilder: (context, index) {
                final supplier = _filteredSuppliers[index];
                return ListTile(
                  title: Text('${supplier.names} ${supplier.lastName}'),
                  onTap: () {
                    Navigator.pop(context, supplier);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
