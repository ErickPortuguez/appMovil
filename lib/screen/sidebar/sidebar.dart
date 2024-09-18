import 'package:flutter/material.dart';
import 'package:myapp/models/seller_model.dart';
import 'package:myapp/screen/login_screen.dart';
import 'package:myapp/screen/pages/client/client_page.dart';
import 'package:myapp/screen/pages/dashboard.dart';
import 'package:myapp/screen/pages/product/product_page.dart';
import 'package:myapp/screen/pages/seller/seller_page.dart';
import 'package:myapp/screen/pages/supplier/supplier_page.dart';
import 'package:myapp/screen/sidebar/my_drawer_header.dart';
import 'package:myapp/screen/pages/account/account_page.dart';
import 'package:myapp/screen/pages/category/category_page.dart';
import 'package:myapp/screen/pages/purchase/purchase_page.dart';
import 'package:myapp/screen/pages/sale/sale_page.dart';

class HomePage extends StatefulWidget {
  final Seller seller;

  const HomePage({Key? key, required this.seller}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var currentPage = DrawerSections.dashboard;

  @override
  Widget build(BuildContext context) {
    Widget container;
    var appBarTitle = DrawerSections.dashboard.title; // Valor predeterminado
    List<Widget> actions = []; // Lista de acciones para la AppBar

    switch (currentPage) {
      case DrawerSections.dashboard:
        container = DashboardPage();
        break;
      case DrawerSections.clients:
        container = const ClientsPage();
        appBarTitle = DrawerSections.clients.title;
        break;
      case DrawerSections.sellers:
        container = const SellersPage();
        appBarTitle = DrawerSections.sellers.title;
        break;
      case DrawerSections.categorys:
        container = const CategorysPage();
        appBarTitle = DrawerSections.categorys.title;
        break;
      case DrawerSections.products:
        container = const ProductsPage();
        appBarTitle = DrawerSections.products.title;
        break;
      case DrawerSections.suppliers:
        container = const SuppliersPage();
        appBarTitle = DrawerSections.suppliers.title;
        break;
      case DrawerSections.sales:
        container = const SalesPage();
        appBarTitle = DrawerSections.sales.title;
        break;
      case DrawerSections.purchases:
        container = const PurchasePage();
        appBarTitle = DrawerSections.purchases.title;
        break;
      case DrawerSections.account:
        container = const SettingsPage();
        appBarTitle = DrawerSections.account.title;
        break;
      case DrawerSections.logout:
        container = const LoginScreen();
        appBarTitle = DrawerSections.logout.title;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        title: Text(
          appBarTitle,
          style: const TextStyle(color: Colors.white),
        ),
        actions: actions, // Añadir las acciones aquí
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: container,
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyHeaderDrawer(
                names: widget.seller.names,
                lastName: widget.seller.lastName,
                email: widget.seller.email,
              ),
              MyDrawerList(widget.seller.sellerRol), // Pasar el rol del usuario
            ],
          ),
        ),
      ),
    );
  }

  // Función que construye la lista de elementos del menú lateral
  Widget MyDrawerList(String rolPerson) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          menuItem(DrawerSections.dashboard),
          menuItem(DrawerSections.clients),
          if (rolPerson == 'Administrador') menuItem(DrawerSections.sellers),
          menuItem(DrawerSections.categorys),
          menuItem(DrawerSections.products),
          menuItem(DrawerSections.suppliers),
          menuItem(DrawerSections.sales),
          menuItem(DrawerSections.purchases),
          const Divider(),
          menuItem(DrawerSections.account),
          const Divider(),
          menuItem(DrawerSections.logout),
        ],
      ),
    );
  }

  // Función que construye un elemento del menú
  Widget menuItem(DrawerSections section) {
    return Material(
      color: currentPage == section ? Colors.grey[300] : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (section == DrawerSections.logout) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pop(context);
            setState(() {
              currentPage = section;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  _getIconForSection(section),
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función que devuelve el ícono correspondiente a cada sección del menú
  IconData _getIconForSection(DrawerSections section) {
    switch (section) {
      case DrawerSections.dashboard:
        return Icons.dashboard_outlined;
      case DrawerSections.clients:
        return Icons.groups;
      case DrawerSections.sellers:
        return Icons.group;
      case DrawerSections.categorys:
        return Icons.category;
      case DrawerSections.products:
        return Icons.sell;
      case DrawerSections.suppliers:
        return Icons.contact_page;
      case DrawerSections.sales:
        return Icons.point_of_sale;
      case DrawerSections.purchases:
        return Icons.shopping_cart;
      case DrawerSections.account:
        return Icons.person;
      case DrawerSections.logout:
        return Icons.logout;
    }
  }
}

enum DrawerSections {
  dashboard,
  clients,
  sellers,
  categorys,
  products,
  suppliers,
  sales,
  purchases,
  account,
  logout,
}

extension DrawerSectionExtension on DrawerSections {
  String get title {
    switch (this) {
      case DrawerSections.dashboard:
        return "Dashboard";
      case DrawerSections.clients:
        return "Clientes";
      case DrawerSections.sellers:
        return "Vendedores";
      case DrawerSections.categorys:
        return "Categorías";
      case DrawerSections.products:
        return "Productos";
      case DrawerSections.suppliers:
        return "Proveedores";
      case DrawerSections.sales:
        return "Ventas";
      case DrawerSections.purchases:
        return "Compras";
      case DrawerSections.account:
        return "Mi Cuenta";
      case DrawerSections.logout:
        return "Cerrar Sesión";
    }
  }
}
