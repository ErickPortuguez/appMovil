// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/screen/pages/seller/seller_modal_page.dart';
import 'package:myapp/services/seller_service.dart';
import 'package:myapp/models/seller_model.dart';

class SellersPage extends StatefulWidget {
  const SellersPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SellersPageState createState() => _SellersPageState();
}

class _SellersPageState extends State<SellersPage> {
  late List<Seller> _sellerList = [];
  late List<Seller> _filteredSellerList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterSellers);
    _loadSellers();
  }

 Future<void> _loadSellers() async {
    try {
      List<Seller> activeSellers = await ApiServiceSeller.getActiveSellers();
      List<Seller> inactiveSellers =
          await ApiServiceSeller.getInactiveSellers();
      _sellerList = [...activeSellers, ...inactiveSellers];
      _filteredSellerList =
          _sellerList; // Inicialmente, muestra todos los vendedore
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los vendedores: $e')),
      );
    }
  }

  void _filterSellers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSellerList = _sellerList.where((seller) {
        return seller.names.toLowerCase().contains(query) ||
            seller.lastName.toLowerCase().contains(query) ||
            seller.email.toLowerCase().contains(query) ||
            seller.numberDocument.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const SizedBox(
                  height: 16.0), // Espacio de 16.0 puntos arriba del TextField
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Buscar Vendedor',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      _navigateToSellerDetail(Seller.empty());
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
                child: Text(
                  'Activos',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Inactivos',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildSellerList(true),
                  _buildSellerList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerList(bool showActive) {
    List<Seller> filteredSellers = _filteredSellerList
        .where((seller) => seller.active == (showActive ? 'A' : 'I'))
        .toList();

    // Verificar si no hay vendedores según la pestaña activa
    if (filteredSellers.isEmpty) {
      return Center(
        child: Text(showActive
            ? 'No hay vendedores activos'
            : 'No hay vendedores inactivos'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredSellers.length,
      itemBuilder: (context, index) {
        Seller seller = filteredSellers[index];
        bool isActive = seller.active == 'A';
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
              '${seller.names} ${seller.lastName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              seller.email,
              style: const TextStyle(
                color: Color.fromARGB(255, 79, 79, 79),
                fontSize: 12,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '${seller.names.substring(0, 1)}${seller.lastName.substring(0, 1)}',
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
                      _showConfirmationDialog(context, seller);
                    },
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.restore,
                      color: Color.fromARGB(255, 0, 104, 248),
                      size: 20,
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context, seller);
                    },
                  ),
            onTap: () {
              if (isActive) {
                _navigateToSellerDetail(seller);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se puede abrir el formulario para vendedores inactivos.',
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
    );
  }

  void _showConfirmationDialog(BuildContext context, Seller seller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(seller.active == 'A'
              ? "Eliminar Vendedor"
              : "Restaurar Vendedor"),
          content: Text(seller.active == 'A'
              ? "¿Estás seguro de eliminar este vendedor?"
              : "¿Estás seguro de restaurar este vendedor?"),
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
                if (seller.active == 'A') {
                  _deleteSeller(context, seller.id);
                } else {
                  _restoreSeller(context, seller.id);
                }
              },
              child: Text(
                  seller.active == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSeller(BuildContext context, int sellerId) async {
    try {
      await ApiServiceSeller.deleteSeller(sellerId);
      _loadSellers();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendedor eliminado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el vendedor: $e')),
      );
    }
  }

  void _restoreSeller(BuildContext context, int sellerId) async {
    try {
      await ApiServiceSeller.activeSeller(sellerId);
      _loadSellers();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendedor restaurado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar el Vendedor: $e')),
      );
    }
  }

  void _handleSellerSaved(Seller seller, bool isNewSeller) {
    _loadSellers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewSeller
              ? 'Vendedor insertado exitosamente'
              : 'Vendedor editado exitosamente',
        ),
      ),
    );
  }

  void _navigateToSellerDetail(Seller seller) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerModalPage(
          seller: seller,
          onSellerSaved: _handleSellerSaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSellers);
    _searchController.dispose();
    super.dispose();
  }
}
