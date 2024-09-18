// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/screen/pages/product/product_modal_page.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/models/product_model.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late List<Product> _productList = [];
  late List<Product> _filteredProductList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterProducts);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      List<Product> activeProducts =
          await ApiServiceProduct.getActiveProducts();
      List<Product> inactiveProducts =
          await ApiServiceProduct.getInactiveProducts();
      List<Product> stockProducts = await ApiServiceProduct.getStockProducts();
      List<Product> expiryProducts =
          await ApiServiceProduct.getExpiryProducts();

      // Eliminar duplicados usando un Set
      // ignore: prefer_collection_literals
      Set<int> uniqueProductIds = Set();
      _productList = [];

      // Agregar productos activos
      for (var product in activeProducts) {
        if (!uniqueProductIds.contains(product.id)) {
          _productList.add(product);
          uniqueProductIds.add(product.id);
        }
      }

      // Agregar productos inactivos
      for (var product in inactiveProducts) {
        if (!uniqueProductIds.contains(product.id)) {
          _productList.add(product);
          uniqueProductIds.add(product.id);
        }
      }

      // Agregar productos con bajo stock
      for (var product in stockProducts) {
        if (!uniqueProductIds.contains(product.id)) {
          _productList.add(product);
          uniqueProductIds.add(product.id);
        }
      }

      // Agregar productos próximos a vencer
      for (var product in expiryProducts) {
        if (!uniqueProductIds.contains(product.id)) {
          _productList.add(product);
          uniqueProductIds.add(product.id);
        }
      }
      // Ordenar la lista completa de productos alfabéticamente
      _productList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      _filteredProductList =
          _productList; // Mostrar inicialmente todos los productos
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los productos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length:
          4, // Cuatro pestañas: Activos, Inactivos, Stock, Próximos a vencer
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const SizedBox(height: 16.0),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Buscar productos',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      _navigateToProductDetail(Product.empty());
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.black,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.cancel,
                  color: Colors.black,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.trending_down,
                  color: Colors.black,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.date_range,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductList(true, 'Lista de Activos'), // Productos Activos
            _buildProductList(
                false, 'Lista de Inactivos'), // Productos Inactivos
            _buildProductListStock(
                'Lista de Bajo Stock'), // Productos con Bajo Stock
            _buildProductListExpiry(
                'Lista de Próximos a Vencer'), // Productos Próximos a Vencer
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(bool showActive, String title) {
    List<Product> filteredProducts = _filteredProductList
        .where((product) => product.active == (showActive ? 'A' : 'I'))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Text(showActive
                      ? 'No hay Productos activos'
                      : 'No hay Productos inactivos'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    Product product = filteredProducts[index];
                    bool isActive = product.active == 'A';
                    return _buildProductListItem(product, isActive);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16.0),
                ),
        ),
      ],
    );
  }

  Widget _buildProductListStock(String title) {
    List<Product> stockProducts =
        _filteredProductList.where((product) => product.stock < 10).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: stockProducts.isEmpty
              ? const Center(
                  child: Text('No hay Productos con bajo stock'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: stockProducts.length,
                  itemBuilder: (context, index) {
                    Product product = stockProducts[index];
                    return _buildStockProductListItem(product);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16.0),
                ),
        ),
      ],
    );
  }

  Widget _buildStockProductListItem(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              'Stock: ${product.stock}',
              style: const TextStyle(
                color: Color.fromARGB(255, 79, 79, 79),
                fontSize: 12,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                product.name.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListExpiry(String title) {
    List<Product> expiryProducts = _filteredProductList
        .where((product) =>
            product.dateExpiry != null &&
            product.dateExpiry!
                .isBefore(DateTime.now().add(const Duration(days: 30))))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: expiryProducts.isEmpty
              ? const Center(
                  child: Text('No hay Productos próximos a vencer'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: expiryProducts.length,
                  itemBuilder: (context, index) {
                    Product product = expiryProducts[index];
                    return _buildExpiryProductListItem(product);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16.0),
                ),
        ),
      ],
    );
  }

  Widget _buildExpiryProductListItem(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                product.name.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(Product product, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Precio de Venta: ${product.priceUnit}\nUnidad de Venta: ${product.unitSale}',
          style: const TextStyle(
            color: Color.fromARGB(255, 79, 79, 79),
            fontSize: 12,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            product.name.substring(0, 1),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        trailing: isActive
            ? IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 248, 0, 0),
                  size: 20,
                ),
                onPressed: () {
                  _showConfirmationDialog(context, product);
                },
              )
            : IconButton(
                icon: const Icon(
                  Icons.restore,
                  color: Color.fromARGB(255, 0, 104, 248),
                  size: 20,
                ),
                onPressed: () {
                  _showConfirmationDialog(context, product);
                },
              ),
        onTap: () {
          if (isActive) {
            _navigateToProductDetail(product);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No se puede abrir el formulario para productos inactivos.',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.active == 'A'
              ? "Eliminar Producto"
              : "Restaurar Producto"),
          content: Text(product.active == 'A'
              ? "¿Estás seguro de eliminar este producto?"
              : "¿Estás seguro de restaurar este producto?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (product.active == 'A') {
                  _deleteProduct(context, product.id);
                } else {
                  _restoreProduct(context, product.id);
                }
              },
              child: Text(
                product.active == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(BuildContext context, int productId) async {
    try {
      await ApiServiceProduct.deleteProduct(productId);
      _loadProducts();
      Navigator.of(context).pop(); // Cerrar el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el Producto: $e')),
      );
    }
  }

  void _restoreProduct(BuildContext context, int productId) async {
    try {
      await ApiServiceProduct.activeProduct(productId);
      _loadProducts();
      Navigator.of(context).pop(); // Cerrar el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto restaurado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar el Producto: $e')),
      );
    }
  }

  void _handleProductSaved(Product product, bool isNewProduct) {
    _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewProduct
              ? 'Producto insertado exitosamente'
              : 'Producto editado exitosamente',
        ),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductModalPage(
          product: product,
          onProductSaved: _handleProductSaved,
        ),
      ),
    );
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProductList = _productList.where((product) {
        // Convertir priceUnit y stock a String para la comparación
        String priceUnitString = product.priceUnit.toString();
        String stockString = product.stock.toString();
        return product.name.toLowerCase().contains(query) ||
            priceUnitString.contains(query) ||
            product.unitSale.toLowerCase().contains(query) ||
            stockString.contains(query) ||
            product.categoryProduct.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }
}
