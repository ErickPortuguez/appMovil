import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myapp/models/supplier_model.dart';
import 'package:myapp/models/paymentMethod_model.dart';
import 'package:myapp/models/product_model.dart';
import 'package:myapp/models/purchase_detail_model.dart';
import 'package:myapp/models/purchase_model.dart';
import 'package:myapp/models/seller_model.dart';
import 'package:myapp/screen/pages/purchase/supplier_selection_screen.dart';
import 'package:myapp/screen/pages/purchase/payment_selection_screen.dart';
import 'package:myapp/screen/pages/purchase/seller_selection_screen.dart';
import 'package:myapp/services/purchase_service.dart';
import 'package:myapp/screen/pages/purchase/product_selection_screen.dart';

class PurchaseModalPage extends StatefulWidget {
  final Purchase purchase;
  final Function(Purchase, bool) onPurchaseSaved;

  const PurchaseModalPage({
    super.key,
    required this.purchase,
    required this.onPurchaseSaved,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PurchaseModalPageState createState() => _PurchaseModalPageState();
}

class _PurchaseModalPageState extends State<PurchaseModalPage> {
  late TextEditingController _supplierController;
  late TextEditingController _sellerController;
  late TextEditingController _paymentMethodController;
  List<PurchaseDetail> _purchaseDetails = [];

  @override
  void initState() {
    super.initState();
    _supplierController =
        TextEditingController(text: widget.purchase.supplierNames);
    _sellerController =
        TextEditingController(text: widget.purchase.sellerNames);
    _paymentMethodController =
        TextEditingController(text: widget.purchase.paymentMethod.name);
    _purchaseDetails.addAll(widget.purchase
        .purchaseDetails); // Clonar la lista para evitar mutaciones inesperadas
  }

  void _saveSale() async {
    // Validar que todos los campos estén completos
    if (_supplierController.text.isEmpty ||
        _sellerController.text.isEmpty ||
        _paymentMethodController.text.isEmpty ||
        _purchaseDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
        ),
      );
      return;
    }

    try {
      final purchase = Purchase(
        id: widget.purchase.id,
        supplier: widget.purchase.supplier,
        seller: widget.purchase.seller,
        paymentMethod: widget.purchase
            .paymentMethod, // Asegúrate de usar el método de pago actualizado
        dateTime: widget.purchase.dateTime.isNotEmpty
            ? widget.purchase.dateTime
            : DateTime.now().toIso8601String(),
        purchaseDetails: _purchaseDetails,
      );

      if (widget.purchase.id == null) {
        await PurchaseService.createPurchase(purchase);
      } else {
        await PurchaseService.updatePurchase(purchase.id!, purchase);
      }

      widget.onPurchaseSaved(purchase, widget.purchase.id == null);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la compra: $e')),
      );
    }
  }

  void _selectSupplier() async {
    final selectedSupplier = await Navigator.push<Supplier?>(
      context,
      MaterialPageRoute(
        builder: (context) => const SupplierListScreen(),
      ),
    );

    if (selectedSupplier != null) {
      setState(() {
        widget.purchase.supplier = selectedSupplier;
        _supplierController.text =
            '${selectedSupplier.names} ${selectedSupplier.lastName}';
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
        widget.purchase.seller = selectedSeller;
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
        widget.purchase.paymentMethod = selectedMethod;
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
    double quantity = 1; // Inicializa la cantidad en 1 por defecto
    TextEditingController quantityController = TextEditingController(
      text: quantity.toStringAsFixed(product.unitSale == 'Kilo' ? 2 : 0),
    );

    bool allowDecimals = product.unitSale == 'Kilo';
    double unitPrice = 0.0;
    TextEditingController unitPriceController = TextEditingController();

    // Encuentra el detalle existente si el producto ya está en la lista de compras
    PurchaseDetail? existingDetail;
    for (var detail in _purchaseDetails) {
      if (detail.product.id == product.id) {
        existingDetail = detail;
        break;
      }
    }
    if (existingDetail != null) {
      // Si ya existe, muestra el modal con la cantidad y precio unitario existentes
      quantity = existingDetail.amount;
      unitPrice = existingDetail.priceUnit;
      quantityController.text = quantity.toStringAsFixed(allowDecimals ? 2 : 0);
      unitPriceController.text = unitPrice.toStringAsFixed(2);
    }

    // Muestra el modal bottom sheet para editar cantidad y precio unitario
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateTotal() {
              setState(() {
                quantity = double.tryParse(quantityController.text) ?? 0;
                unitPrice = double.tryParse(unitPriceController.text) ?? 0;
              });
            }

            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
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
                      'Unidad de Venta: ${product.unitSale}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Stock: ${product.stock}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (quantity > 0) {
                                if (allowDecimals) {
                                  quantity -= 0.1;
                                } else {
                                  quantity--;
                                }
                                quantity = _roundToDecimals(
                                    quantity, allowDecimals ? 2 : 0);
                                quantityController.text = quantity
                                    .toStringAsFixed(allowDecimals ? 2 : 0);
                                updateTotal();
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
                                    decimal: allowDecimals,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Cantidad',
                                  ),
                                  onChanged: (value) {
                                    updateTotal();
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
                            radius: 30,
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
                                quantity += 0.1;
                              } else {
                                quantity++;
                              }
                              quantity = _roundToDecimals(
                                  quantity, allowDecimals ? 2 : 0);
                              quantityController.text = quantity
                                  .toStringAsFixed(allowDecimals ? 2 : 0);
                              updateTotal();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Precio Unitario: ',
                          style: TextStyle(fontSize: 18),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:
                                      const Text('Ingrese el precio unitario'),
                                  content: TextField(
                                    controller: unitPriceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Precio Unitario',
                                    ),
                                    onChanged: (value) {
                                      updateTotal();
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
                            child: Text(
                              unitPriceController.text.isEmpty
                                  ? 'Ingrese el precio'
                                  : 'S/. ${unitPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total: S/. ${(unitPrice * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Actualiza o agrega el detalle del producto a la lista de compras
                              if (existingDetail != null) {
                                setState(() {
                                  existingDetail!.amount = quantity;
                                  existingDetail.priceUnit = unitPrice;
                                });
                              } else {
                                setState(() {
                                  _purchaseDetails.add(PurchaseDetail(
                                    product: product,
                                    amount: quantity,
                                    priceUnit: unitPrice,
                                  ));
                                });
                              }
                              Navigator.pop(context);
                              _updateForm(); // Actualiza el formulario después de agregar o actualizar el producto
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              existingDetail != null ? 'Actualizar' : 'Agregar',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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
        itemCount: _purchaseDetails.length,
        itemBuilder: (context, index) {
          final saleDetail = _purchaseDetails[index];
          final product = saleDetail.product;
          final totalPrice = saleDetail.amount * saleDetail.priceUnit;

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
                    '${saleDetail.amount} x S/.${saleDetail.priceUnit.toStringAsFixed(2)}',
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
                    _purchaseDetails.removeAt(index); // Eliminar el producto
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
    for (var saleDetail in _purchaseDetails) {
      totalAmount += saleDetail.amount * saleDetail.priceUnit;
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
          widget.purchase.id == null ? 'Nueva Compra' : 'Editar Compra',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _selectSupplier,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Proveedor',
                  prefixIcon: Icon(Icons.person),
                  suffixIcon: Icon(Icons.navigate_next),
                ),
                child: Text(
                  _supplierController.text.isNotEmpty
                      ? _supplierController.text
                      : 'Selecciona un proveedor',
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
              child: Text(widget.purchase.id == null
                  ? 'Guardar Compra'
                  : 'Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
