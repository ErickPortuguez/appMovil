// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:myapp/models/purchase_model.dart';
import 'package:myapp/services/purchase_service.dart';
import 'package:myapp/screen/pages/purchase/purchase_modal_page.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasePage> {
  late List<Purchase> _purchaseList = [];
  late List<Purchase> _filteredPurchaseList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterPurchases);
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    try {
      List<Purchase> activePurchases = await PurchaseService.getActivePurchases();
      List<Purchase> inactivePurchases = await PurchaseService.getInactivePurchases();
      _purchaseList = [...activePurchases, ...inactivePurchases];
      _filteredPurchaseList =
          _purchaseList; // Asegúrate de que _purchaseList esté completamente inicializado aquí
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las compras: $e')),
      );
    }
  }

  void _filterPurchases() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPurchaseList = _purchaseList.where((purchase) {
        bool matchesClientName =
            purchase.supplierNames?.toLowerCase().contains(query) ?? false;
        bool matchesSellerName =
            purchase.sellerNames?.toLowerCase().contains(query) ?? false;
        bool matchesTotal = purchase.totalPurchase?.toString().contains(query) ?? false;
        bool matchesDateTime = purchase.formattedDateTime!.contains(query);
        return matchesClientName ||
            matchesSellerName ||
            matchesTotal ||
            matchesDateTime;
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
              const SizedBox(height: 16.0),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Buscar Compra',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black, size: 28),
                    onPressed: () {
                      _navigateToPurchaseDetail(Purchase.empty());
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
                  child:
                      Text('Activas', style: TextStyle(color: Colors.black))),
              Tab(
                  child:
                      Text('Inactivas', style: TextStyle(color: Colors.black))),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildPurchaseList(true),
                  _buildPurchaseList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseList(bool showActive) {
    List<Purchase> filteredPurchases = _filteredPurchaseList
        .where((purchase) => purchase.active == (showActive ? 'A' : 'I'))
        .toList();

    if (filteredPurchases.isEmpty) {
      return Center(
        child: Text(
            showActive ? 'No hay compras activas' : 'No hay compras inactivas'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredPurchases.length,
      itemBuilder: (context, index) {
        Purchase purchase = filteredPurchases[index];
        bool isActive = purchase.active == 'A';
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3.0),
          padding: const EdgeInsets.all(
              10.0), // Aumentar el padding para hacer el card más grande
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'N° de venta: ${purchase.id}\nProveedor: ${purchase.supplierNames}\nVendedor: ${purchase.sellerNames}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha: ${purchase.formattedDateTime}',
                ),
                const SizedBox(
                    height:
                        3), // Espacio adicional entre cliente/vendedor y total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: S/.${purchase.totalPurchase?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isActive ? Icons.delete : Icons.restore,
                    color: isActive ? Colors.red : Colors.blue,
                    size: 24,
                  ),
                  onPressed: () {
                    _showConfirmationDialog(context, purchase);
                  },
                ),
              ],
            ),
            onTap: () {
              if (isActive) {
                _navigateToPurchaseDetail(purchase);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'No se puede abrir el formulario para ventas inactivas.'),
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

  void _showConfirmationDialog(BuildContext context, Purchase purchase) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(purchase.active == 'A' ? "Eliminar Venta" : "Restaurar Venta"),
          content: Text(purchase.active == 'A'
              ? "¿Estás seguro de eliminar esta venta?"
              : "¿Estás seguro de restaurar esta venta?"),
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
                if (purchase.active == 'A') {
                  _deletePurchase(context, purchase.id!);
                } else {
                  _restorePurchase(context, purchase.id!);
                }
              },
              child: Text(purchase.active == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deletePurchase(BuildContext context, int purchaseId) async {
    try {
      await PurchaseService.logicalDeletePurchase(purchaseId);
      _loadPurchases();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta eliminada exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la venta: $e')),
      );
    }
  }

  void _restorePurchase(BuildContext context, int purchaseId) async {
    try {
      await PurchaseService.activatePurchase(purchaseId);
      _loadPurchases();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta restaurada exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar la venta: $e')),
      );
    }
  }

  void _handlePurchaseSaved(Purchase purchase, bool isNewPurchase) {
    _loadPurchases();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewPurchase
              ? 'Venta insertada exitosamente'
              : 'Venta editada exitosamente',
        ),
      ),
    );
  }

  void _navigateToPurchaseDetail(Purchase purchase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseModalPage(
          purchase: purchase,
          onPurchaseSaved: _handlePurchaseSaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPurchases);
    _searchController.dispose();
    super.dispose();
  }
}
