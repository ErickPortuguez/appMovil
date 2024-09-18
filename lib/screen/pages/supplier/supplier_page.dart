// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/screen/pages/supplier/supplier_modal_page.dart';
import 'package:myapp/services/supplier_service.dart';
import 'package:myapp/models/supplier_model.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SuppliersPageState createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  late List<Supplier> _supplierList = [];
  late List<Supplier> _filteredSupplierList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterSuppliers);
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      List<Supplier> activeSuppliers =
          await ApiServiceSupplier.getActiveSuppliers();
      List<Supplier> inactiveSuppliers =
          await ApiServiceSupplier.getInactiveSuppliers();
      _supplierList = [...activeSuppliers, ...inactiveSuppliers];
      _filteredSupplierList =
          _supplierList; // Inicialmente, muestra todos los supplieres
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los supplieres: $e')),
      );
    }
  }

  void _filterSuppliers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSupplierList = _supplierList.where((supplier) {
        return supplier.nameCompany.toLowerCase().contains(query) ||
            supplier.ruc.contains(query) ||
            supplier.names.toLowerCase().contains(query) ||
            supplier.lastName.toLowerCase().contains(query) ||
            supplier.email.toLowerCase().contains(query);
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
                  hintText: 'Buscar supplieres',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      _navigateToSupplierDetail(Supplier.empty());
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
                  _buildSupplierList(true),
                  _buildSupplierList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierList(bool showActive) {
    List<Supplier> filteredSuppliers = _filteredSupplierList
        .where((supplier) => supplier.active == (showActive ? 'A' : 'I'))
        .toList();

    // Verificar si no hay supplieres según la pestaña activa
    if (filteredSuppliers.isEmpty) {
      return Center(
        child: Text(showActive
            ? 'No hay Proveedores activos'
            : 'No hay Proveedores inactivos'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredSuppliers.length,
      itemBuilder: (context, index) {
        Supplier supplier = filteredSuppliers[index];
        bool isActive = supplier.active == 'A';
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
              '${supplier.names} ${supplier.lastName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              supplier.nameCompany,
              style: const TextStyle(
                color: Color.fromARGB(255, 79, 79, 79),
                fontSize: 12,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                supplier.nameCompany.substring(0, 1),
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
                      _showConfirmationDialog(context, supplier);
                    },
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.restore,
                      color: Color.fromARGB(255, 0, 104, 248),
                      size: 20,
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context, supplier);
                    },
                  ),
            onTap: () {
              if (isActive) {
                _navigateToSupplierDetail(supplier);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se puede abrir el formulario para proveedores inactivos.',
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

  void _showConfirmationDialog(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(supplier.active == 'A'
              ? "Eliminar Proveedor"
              : "Restaurar Proveedor"),
          content: Text(supplier.active == 'A'
              ? "¿Estás seguro de eliminar este proveedor?"
              : "¿Estás seguro de restaurar este proveedor?"),
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
                if (supplier.active == 'A') {
                  _deleteSupplier(context, supplier.id);
                } else {
                  _restoreSupplier(context, supplier.id);
                }
              },
              child: Text(
                  supplier.active == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSupplier(BuildContext context, int supplierId) async {
    try {
      await ApiServiceSupplier.deleteSupplier(supplierId);
      _loadSuppliers();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proveedor eliminado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el Proveedor: $e')),
      );
    }
  }

  void _restoreSupplier(BuildContext context, int supplierId) async {
    try {
      await ApiServiceSupplier.activeSupplier(supplierId);
      _loadSuppliers();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proveedor restaurado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar el Proveedor: $e')),
      );
    }
  }

  void _handleSupplierSaved(Supplier supplier, bool isNewSupplier) {
    _loadSuppliers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewSupplier
              ? 'Proveedor insertado exitosamente'
              : 'Proveedor editado exitosamente',
        ),
      ),
    );
  }

  void _navigateToSupplierDetail(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierModalPage(
          supplier: supplier,
          onSupplierSaved: _handleSupplierSaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSuppliers);
    _searchController.dispose();
    super.dispose();
  }
}
