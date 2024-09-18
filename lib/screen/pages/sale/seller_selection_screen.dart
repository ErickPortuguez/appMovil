import 'package:flutter/material.dart';
import 'package:myapp/models/seller_model.dart';
import 'package:myapp/services/seller_service.dart';

class SellerListScreen extends StatefulWidget {
  const SellerListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SellerListScreenState createState() => _SellerListScreenState();
}

class _SellerListScreenState extends State<SellerListScreen> {
  List<Seller> _sellers = [];
  List<Seller> _filteredSellers = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadSellers();
  }

  Future<void> _loadSellers() async {
    try {
      final sellers = await ApiServiceSeller.getActiveSellers();
      setState(() {
        _sellers = sellers;
        _filteredSellers = sellers;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los vendedores: $e'),
        ),
      );
    }
  }

  void _filterSellers(String query) {
    setState(() {
      _filteredSellers = _sellers
          .where((seller) =>
              seller.names.toLowerCase().contains(query.toLowerCase()) ||
              seller.lastName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Lista de Vendedores',
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
                labelText: 'Buscar Vendedores',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterSellers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSellers.length,
              itemBuilder: (context, index) {
                final seller = _filteredSellers[index];
                return ListTile(
                  title: Text('${seller.names} ${seller.lastName}'),
                  onTap: () {
                    Navigator.pop(context, seller);
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
