import 'package:flutter/material.dart';
import 'package:myapp/models/category_model.dart';
import 'package:myapp/models/client_model.dart';
import 'package:myapp/models/product_model.dart';
import 'package:myapp/models/purchase_model.dart';
import 'package:myapp/models/sale_model.dart';
import 'package:myapp/models/seller_model.dart';
import 'package:myapp/models/supplier_model.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/client_service.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/services/purchase_service.dart';
import 'package:myapp/services/sale_service.dart';
import 'package:myapp/services/seller_service.dart';
import 'package:myapp/services/supplier_service.dart'; // Importa tu servicio API aquí

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Variable para almacenar el número de clientes activos
  int activeClientsCount = 0;
  int activeSellersCount = 0;
  int activeSuppliersCount = 0;
  int activeCategoriesCount = 0;
  int activeProductsCount = 0;
  int activeSalesCount = 0;
  int activePurchasesCount = 0;

  Future<void> _getActiveClients() async {
    try {
      List<Client> activeClients = await ApiServiceClient.getActiveClients();
      setState(() {
        activeClientsCount = activeClients.length;
      });
    } catch (e) {
      print('Error fetching active clients: $e');
    }
  }

  Future<void> _getActiveSelllers() async {
    try {
      List<Seller> activeSellers = await ApiServiceSeller.getActiveSellers();
      setState(() {
        activeSellersCount = activeSellers.length;
      });
    } catch (e) {
      print('Error fetching active sellers: $e');
    }
  }

  Future<void> _getActiveSuppliers() async {
    try {
      List<Supplier> activeSuppliers =
          await ApiServiceSupplier.getActiveSuppliers();
      setState(() {
        activeSuppliersCount = activeSuppliers.length;
      });
    } catch (e) {
      print('Error fetching active suppliers: $e');
    }
  }

  Future<void> _getActiveCategories() async {
    try {
      List<Category> activeCategories =
          await ApiServiceCategory.getActiveCategories();
      setState(() {
        activeCategoriesCount = activeCategories.length;
      });
    } catch (e) {
      print('Error fetching active categories: $e');
    }
  }

  Future<void> _getActiveProducts() async {
    try {
      List<Product> activeProducts =
          await ApiServiceProduct.getActiveProducts();
      setState(() {
        activeProductsCount = activeProducts.length;
      });
    } catch (e) {
      print('Error fetching active products: $e');
    }
  }

  Future<void> _getActiveSales() async {
    try {
      List<Sale> activeSales = await SaleService.getActiveSales();
      setState(() {
        activeSalesCount = activeSales.length;
      });
    } catch (e) {
      print('Error fetching active sales: $e');
    }
  }

  Future<void> _getActivePurchases() async {
    try {
      List<Purchase> activePurchases =
          await PurchaseService.getActivePurchases();
      setState(() {
        activePurchasesCount = activePurchases.length;
      });
    } catch (e) {
      print('Error fetching active purchases: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getActiveClients();
    _getActiveSelllers();
    _getActiveSuppliers();
    _getActiveCategories();
    _getActiveProducts();
    _getActiveSales();
    _getActivePurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Primer fila de tarjetas
              // Cuarta fila de tarjetas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                      'Ventas',
                      activeSalesCount,
                      Icons.attach_money,
                      Colors
                          .deepPurple), // Ejemplo estático, sustituir por valor real si se tiene
                  _buildStatCard(
                      'Compras',
                      activePurchasesCount,
                      Icons.shopping_cart,
                      Colors
                          .deepOrange), // Ejemplo estático, sustituir por valor real si se tiene
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Clientes', activeClientsCount, Icons.people,
                      Colors.blue),
                  _buildStatCard(
                      'Vendedores',
                      activeSellersCount,
                      Icons.person,
                      Colors
                          .orange), // Ejemplo estático, sustituir por valor real si se tiene
                ],
              ),
              const SizedBox(height: 20),
              // Tercera fila de tarjetas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                      'Productos',
                      activeProductsCount,
                      Icons.shopping_basket,
                      Colors
                          .green), // Ejemplo estático, sustituir por valor real si se tiene
                  _buildStatCard(
                      'Categorías',
                      activeCategoriesCount,
                      Icons.category,
                      Colors
                          .teal), // Ejemplo estático, sustituir por valor real si se tiene
                ],
              ),
              const SizedBox(height: 20),
              // Segunda fila de tarjetas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                      'Proveedores',
                      activeSuppliersCount,
                      Icons.business,
                      Colors
                          .purple), // Ejemplo estático, sustituir por valor real si se tiene
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir cada tarjeta de estadística
  Widget _buildStatCard(
      String title, int value, IconData iconData, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
