import 'package:flutter/material.dart';
import 'package:myapp/models/product_model.dart';
import 'package:myapp/services/product_service.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Selecciona Productos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const ProductList(),
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late TextEditingController _searchController;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiServiceProduct.getActiveProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los productos: $e'),
        ),
      );
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showProductDetails(Product product) {
    Navigator.pop(context, product);
  }

  Widget _buildProductListItem(Product product) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      shadowColor: Colors.blue.withOpacity(0.2), // Color de la sombra
      child: InkWell(
        onTap: () => _showProductDetails(product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Precio de Compra: S/.${product.priceUnit.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar producto',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _filterProducts,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return _buildProductListItem(product);
            },
          ),
        ),
      ],
    );
  }
}
