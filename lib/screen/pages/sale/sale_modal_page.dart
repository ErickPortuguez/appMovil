import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myapp/models/client_model.dart';
import 'package:myapp/models/paymentMethod_model.dart';
import 'package:myapp/models/product_model.dart';
import 'package:myapp/models/sale_detail_model.dart';
import 'package:myapp/models/sale_model.dart';
import 'package:myapp/models/seller_model.dart';
import 'package:myapp/screen/pages/sale/client_selection_screen.dart';
import 'package:myapp/screen/pages/sale/payment_selection_screen.dart';
import 'package:myapp/screen/pages/sale/seller_selection_screen.dart';
import 'package:myapp/services/sale_service.dart';
import 'package:myapp/screen/pages/sale/product_selection_screen.dart';

class SaleModalPage extends StatefulWidget {
  final Sale sale;
  final Function(Sale, bool) onSaleSaved;

  const SaleModalPage({
    Key? key,
    required this.sale,
    required this.onSaleSaved,
  }) : super(key: key);

  @override
  _SaleModalPageState createState() => _SaleModalPageState();
}

class _SaleModalPageState extends State<SaleModalPage> {
  late TextEditingController _clientController;
  late TextEditingController _sellerController;
  late TextEditingController _paymentMethodController;
  List<SaleDetail> _saleDetails = [];

  @override
  void initState() {
    super.initState();
    _clientController = TextEditingController(text: widget.sale.clientNames);
    _sellerController = TextEditingController(text: widget.sale.sellerNames);
    _paymentMethodController =
        TextEditingController(text: widget.sale.paymentMethod.name);
    _saleDetails.addAll(widget.sale
        .saleDetails); // Clonar la lista para evitar mutaciones inesperadas
  }

  void _saveSale() async {
    // Validar que todos los campos estén completos
    if (_clientController.text.isEmpty ||
        _sellerController.text.isEmpty ||
        _paymentMethodController.text.isEmpty ||
        _saleDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
        ),
      );
      return;
    }

    try {
      final sale = Sale(
        id: widget.sale.id,
        client: widget.sale.client,
        seller: widget.sale.seller,
        paymentMethod: widget.sale
            .paymentMethod, // Asegúrate de usar el método de pago actualizado
        dateTime: widget.sale.dateTime.isNotEmpty
            ? widget.sale.dateTime
            : DateTime.now().toIso8601String(),
        saleDetails: _saleDetails,
      );

      if (widget.sale.id == null) {
        await SaleService.createSale(sale);
      } else {
        await SaleService.updateSale(sale.id!, sale);
      }

      widget.onSaleSaved(sale, widget.sale.id == null);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la venta: $e')),
      );
    }
  }

  void _selectClient() async {
    final selectedClient = await Navigator.push<Client?>(
      context,
      MaterialPageRoute(
        builder: (context) => const ClientListScreen(),
      ),
    );

    if (selectedClient != null) {
      setState(() {
        widget.sale.client = selectedClient;
        _clientController.text =
            '${selectedClient.names} ${selectedClient.lastName}';
      });
    }
  }

  void _selectSeller() async {
    final selectedSeller = await Navigator.push<Seller?>(
      context,
      MaterialPageRoute(
        builder: (context) => const SellerListScreen(),
      ),
    );

    if (selectedSeller != null) {
      setState(() {
        widget.sale.seller = selectedSeller;
        _sellerController.text =
            '${selectedSeller.names} ${selectedSeller.lastName}';
      });
    }
  }

  void _selectpaymentMethodMethod() async {
    final selectedMethod = await Navigator.push<PaymentMethod?>(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentMethodListScreen(),
      ),
    );

    if (selectedMethod != null) {
      setState(() {
        widget.sale.paymentMethod = selectedMethod;
        _paymentMethodController.text = selectedMethod.name;
      });
    }
  }

  void _addProduct() async {
    final Product? selectedProduct = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductListScreen()),
    );

    if (selectedProduct != null) {
      _showProductDetails(selectedProduct);
    }
  }

  void _showProductDetails(Product product) {
    double quantity = 1; // Inicializar la cantidad en 1 como double
    TextEditingController quantityController = TextEditingController(
      text: quantity.toStringAsFixed(product.unitSale == 'Kilo'
          ? 2
          : 0), // Mostrar hasta 2 decimales si es Kilo
    );

    // Verificar la unidad de venta del producto
    bool allowDecimals = product.unitSale == 'Kilo';

    // Buscar si el producto ya está en la lista de detalles
    SaleDetail? existingDetail;
    for (var detail in _saleDetails) {
      if (detail.product.id == product.id) {
        existingDetail = detail;
        break;
      }
    }

    if (existingDetail != null) {
      // Si ya existe, mostrar modal con la cantidad existente
      quantity = existingDetail.amount;
      quantityController.text = quantity.toStringAsFixed(allowDecimals ? 2 : 0);
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Precio de Venta: S/.${product.priceUnit.toStringAsFixed(2)}\n Unidad de Venta: ${product.unitSale}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Stock: ${product.stock}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (quantity > 0) {
                            if (allowDecimals) {
                              // Para unidades como Kilo, permitir decrementar en 0.1
                              quantity -= 0.1;
                            } else {
                              quantity--;
                            }
                            quantity = _roundToDecimals(
                                quantity, allowDecimals ? 2 : 0);
                            quantityController.text =
                                quantity.toStringAsFixed(allowDecimals ? 2 : 0);
                          }
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Ingrese la cantidad'),
                            content: TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: allowDecimals),
                              decoration: const InputDecoration(
                                hintText: 'Cantidad',
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    quantity = double.parse(value);
                                    quantity = _roundToDecimals(
                                        quantity, allowDecimals ? 2 : 0);
                                  });
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 30, // Ajusta el radio según tu preferencia
                        child: Text(
                          quantity.toStringAsFixed(allowDecimals ? 2 : 0),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (allowDecimals) {
                            // Para unidades como Kilo, permitir incrementar en 0.1
                            quantity += 0.1;
                          } else {
                            quantity++;
                          }
                          quantity =
                              _roundToDecimals(quantity, allowDecimals ? 2 : 0);
                          quantityController.text =
                              quantity.toStringAsFixed(allowDecimals ? 2 : 0);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Total: S/.${(product.priceUnit * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (existingDetail != null) {
                          // Actualizar la cantidad del producto existente
                          setState(() {
                            existingDetail!.amount = quantity;
                          });
                        } else {
                          // Agregar el producto a la lista de detalles de venta
                          setState(() {
                            _saleDetails.add(SaleDetail(
                              product: product,
                              amount: quantity,
                            ));
                          });
                        }
                        Navigator.pop(context);
                        _updateForm(); // Actualizar el formulario después de agregar o actualizar el producto
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        existingDetail != null
                            ? 'Actualizar cantidad'
                            : 'Agregar a la venta',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Función para redondear un número a cierta cantidad de decimales
  double _roundToDecimals(double number, int decimals) {
    num fac = pow(10, decimals);
    return (number * fac).round() / fac;
  }

  Widget _buildProductList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _saleDetails.length,
        itemBuilder: (context, index) {
          final saleDetail = _saleDetails[index];
          final product = saleDetail.product;
          final totalPrice = saleDetail.amount * product.priceUnit;

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              onTap: () {
                _showProductDetails(
                    product); // Mostrar modal para editar cantidad
              },
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${saleDetail.amount} x S/.${product.priceUnit.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total: S/.${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle,
                    color: Colors.red), // Color rojo
                onPressed: () {
                  setState(() {
                    _saleDetails.removeAt(index); // Eliminar el producto
                    _updateForm(); // Actualizar el formulario después de eliminar
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  double _calculateTotalAmount() {
    double totalAmount = 0;
    for (var saleDetail in _saleDetails) {
      totalAmount += saleDetail.amount * saleDetail.product.priceUnit;
    }
    return totalAmount;
  }

  void _updateForm() {
    setState(() {
      // Forzar la actualización del estado del formulario
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.sale.id == null ? 'Nueva Venta' : 'Editar Venta',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _selectClient,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.person),
                  suffixIcon: Icon(Icons.navigate_next),
                ),
                child: Text(
                  _clientController.text.isNotEmpty
                      ? _clientController.text
                      : 'Selecciona un cliente',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectSeller,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Vendedor',
                  prefixIcon: Icon(Icons.person_outline),
                  suffixIcon: Icon(Icons.navigate_next),
                ),
                child: Text(
                  _sellerController.text.isNotEmpty
                      ? _sellerController.text
                      : 'Selecciona un vendedor',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectpaymentMethodMethod,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  prefixIcon: Icon(Icons.payment),
                  suffixIcon: Icon(Icons.navigate_next),
                ),
                child: Text(
                  _paymentMethodController.text.isNotEmpty
                      ? _paymentMethodController.text
                      : 'Selecciona un método de pago',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Añadir Producto'),
            ),
            const SizedBox(height: 16),
            _buildProductList(),
            const SizedBox(height: 16),
            Text(
              'Monto a pagar: S/.${_calculateTotalAmount().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSale,
              child: Text(
                  widget.sale.id == null ? 'Guardar Venta' : 'Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
