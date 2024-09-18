import 'package:flutter/material.dart';
import 'package:myapp/models/paymentMethod_model.dart';
import 'package:myapp/services/payment_service.dart';

class PaymentMethodListScreen extends StatefulWidget {
  const PaymentMethodListScreen({super.key});

  @override
  _PaymentMethodListScreenState createState() =>
      _PaymentMethodListScreenState();
}

class _PaymentMethodListScreenState extends State<PaymentMethodListScreen> {
  List<PaymentMethod> _paymentMethods = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final paymentMethods =
          await ApiServicePaymentMethod.getActivePaymentMethods();
      setState(() {
        _paymentMethods = paymentMethods;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los métodos de pago: $e'),
        ),
      );
    }
  }

  void _filterPaymentMethods(String query) {
    setState(() {
      _paymentMethods = _paymentMethods
          .where((method) =>
              method.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Lista de Métodos de Pago',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar método de pago',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterPaymentMethods,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                return ListTile(
                  title: Text(method.name),
                  onTap: () {
                    Navigator.pop(
                        context, method); // Devolver el método seleccionado
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
