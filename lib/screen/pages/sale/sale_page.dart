// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:myapp/models/sale_model.dart';
import 'package:myapp/services/sale_service.dart';
import 'package:myapp/screen/pages/sale/sale_modal_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late List<Sale> _saleList = [];
  late List<Sale> _filteredSaleList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterSales);
    _loadSales();
  }

  Future<void> _loadSales() async {
    try {
      List<Sale> activeSales = await SaleService.getActiveSales();
      List<Sale> inactiveSales = await SaleService.getInactiveSales();
      _saleList = [...activeSales, ...inactiveSales];
      _filteredSaleList =
          _saleList; // Asegúrate de que _saleList esté completamente inicializado aquí
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las ventas: $e')),
      );
    }
  }

  void _filterSales() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSaleList = _saleList.where((sale) {
        bool matchesClientName =
            sale.clientNames?.toLowerCase().contains(query) ?? false;
        bool matchesSellerName =
            sale.sellerNames?.toLowerCase().contains(query) ?? false;
        bool matchesTotal = sale.totalSale?.toString().contains(query) ?? false;
        bool matchesDateTime = sale.formattedDateTime!.contains(query);
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
                  hintText: 'Buscar Venta',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black, size: 28),
                    onPressed: () {
                      _navigateToSaleDetail(Sale.empty());
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
                  _buildSaleList(true),
                  _buildSaleList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleList(bool showActive) {
    List<Sale> filteredSales = _filteredSaleList
        .where((sale) => sale.active == (showActive ? 'A' : 'I'))
        .toList();

    if (filteredSales.isEmpty) {
      return Center(
        child: Text(
            showActive ? 'No hay ventas activas' : 'No hay ventas inactivas'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredSales.length,
      itemBuilder: (context, index) {
        Sale sale = filteredSales[index];
        bool isActive = sale.active == 'A';
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
                  'N° de venta: ${sale.id}\nCliente: ${sale.clientNames}\nVendedor: ${sale.sellerNames}',
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
                  'Fecha: ${sale.formattedDateTime}',
                ),
                const SizedBox(
                    height:
                        3), // Espacio adicional entre cliente/vendedor y total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\Total: S/.${sale.totalSale?.toStringAsFixed(2) ?? '0.00'}',
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
                    _showConfirmationDialog(context, sale);
                  },
                ),
              ],
            ),
            onTap: () {
              if (isActive) {
                _navigateToSaleDetail(sale);
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

  void _showConfirmationDialog(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(sale.active == 'A' ? "Eliminar Venta" : "Restaurar Venta"),
          content: Text(sale.active == 'A'
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
                if (sale.active == 'A') {
                  _deleteSale(context, sale.id!);
                } else {
                  _restoreSale(context, sale.id!);
                }
              },
              child: Text(sale.active == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSale(BuildContext context, int saleId) async {
    try {
      await SaleService.logicalDeleteSale(saleId);
      _loadSales();
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

  void _restoreSale(BuildContext context, int saleId) async {
    try {
      await SaleService.activateSale(saleId);
      _loadSales();
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

  void _handleSaleSaved(Sale sale, bool isNewSale) {
    _loadSales();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewSale
              ? 'Venta insertada exitosamente'
              : 'Venta editada exitosamente',
        ),
      ),
    );
  }

  void _navigateToSaleDetail(Sale sale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaleModalPage(
          sale: sale,
          onSaleSaved: _handleSaleSaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSales);
    _searchController.dispose();
    super.dispose();
  }
}
