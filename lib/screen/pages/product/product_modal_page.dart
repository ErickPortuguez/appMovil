// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/product_model.dart';
import 'package:myapp/models/category_model.dart';
import 'package:myapp/screen/pages/product/category_selection_screen.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/product_service.dart';

class ProductModalPage extends StatefulWidget {
  final Product product;
  final Function(Product, bool) onProductSaved;

  const ProductModalPage({
    super.key,
    required this.product,
    required this.onProductSaved,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProductModalPageState createState() => _ProductModalPageState();
}

class _ProductModalPageState extends State<ProductModalPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceUnitController;
  late String _selectedUnitSale;
  late TextEditingController _stockController;
  late TextEditingController _dateExpiryController;
  late DateTime _selectedDate;
  late Category _selectedCategory = Category.empty();
  bool _nameExists = false;
  bool _isNewProduct = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceUnitController = TextEditingController(
        text: widget.product.priceUnit > 0
            ? widget.product.priceUnit.toString()
            : '');
    _stockController = TextEditingController(
        text: widget.product.stock > 0 ? widget.product.stock.toString() : '');
    _selectedDate = widget.product.dateExpiry ?? DateTime.now();
    _dateExpiryController = TextEditingController(
      text: widget.product.dateExpiry != null
          ? _formatDate(widget.product.dateExpiry!)
          : '',
    );
    _isNewProduct = widget.product.id == 0;

    // Inicializa _selectedUnitSale con un valor válido
    _selectedUnitSale =
        widget.product.unitSale.isNotEmpty ? widget.product.unitSale : 'Unidad';

    if (_isNewProduct) {
      _loadCategories();
    } else {
      _loadCategoriesAndSelectCategory();
    }
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateExpiryController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _loadCategoriesAndSelectCategory() async {
    try {
      final categories = await ApiServiceCategory.getActiveCategories();
      final selectedCategory = categories.firstWhere(
        (category) => category.id == widget.product.categoryProduct.id,
        orElse: () => Category.empty(),
      );
      setState(() {
        _selectedCategory = selectedCategory;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las categorías: $e'),
        ),
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiServiceCategory.getActiveCategories();
      setState(() {
        if (categories.isNotEmpty) {
          _selectedCategory = categories.first;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las categorías: $e'),
        ),
      );
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    DateTime? selectedDate = _selectedDate;
    if (_dateExpiryController.text.isEmpty) {
      selectedDate = null;
    }

    try {
      final product = Product(
        id: widget.product.id,
        name: _nameController.text,
        categoryProduct: _selectedCategory,
        priceUnit: double.tryParse(_priceUnitController.text) ?? 0.0,
        unitSale: _selectedUnitSale,
        stock: double.tryParse(_stockController.text) ?? 0.0,
        dateExpiry: selectedDate,
        active: widget.product.active,
      );

      if (_isNewProduct) {
        await ApiServiceProduct.createProduct(product);
      } else {
        await ApiServiceProduct.updateProduct(product);
      }
      widget.onProductSaved(product, _isNewProduct);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el producto: $e'),
        ),
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre del producto';
    }
    // Verificar que cada palabra empiece con mayúscula y permitir espacios
    final RegExp nameRegExp = RegExp(r'^[A-ZÁÉÍÓÚÜÑ][a-zA-Záéíóúüñ\s]*$');

    if (!nameRegExp.hasMatch(value)) {
      return 'Cada palabra debe empezar con mayúscula';
    }
    if (_nameExists) {
      return 'El nombre ya está registrado';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el precio';
    }
    final RegExp numericRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!numericRegex.hasMatch(value)) {
      return 'Ingresa un precio válido';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Ingresa un precio válido';
    }
    return null;
  }

  String? _validateDateExpiry(String? value) {
    if (value != null && value.isNotEmpty) {
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final DateTime? dateExpiry = DateFormat('dd-MMM-yyyy').parse(value);
      if (dateExpiry == null) {
        return 'Fecha de nacimiento inválida';
      }
      final DateTime today = DateTime.now();

      if (!dateExpiry.isAfter(today)) {
        return 'La fecha de expiración debe ser mayor a la fecha actual';
      }
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el stock';
    }

    // Verificar si el valor es numérico
    final stock = double.tryParse(value);
    if (stock == null || stock <= 0) {
      return 'Ingresa un stock válido (mayor que cero)';
    }

    // Verificar formato según la unidad de venta seleccionada
    if (_selectedUnitSale == 'Unidad') {
      // Validación para unidad (debe ser entero)
      if (stock.round() != stock) {
        return 'El stock debe ser un número entero para unidades';
      }
    } else if (_selectedUnitSale == 'Kilo') {
      // Validación para kilo (puede ser entero o decimal con máximo dos decimales)
      if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
        return 'El stock debe ser un número entero o decimal';
      }
    }

    return null; // Validación exitosa
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceUnitController.dispose();
    _stockController.dispose();
    _dateExpiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isNewProduct ? 'Nuevo Producto' : widget.product.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.label),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    // Limpiar la bandera de nombre existente al cambiar el valor
                    setState(() {
                      _nameExists = false;
                    });
                    // Verificar si el nombre existe al cambiar el valor
                    if (value.isNotEmpty) {
                      _checkNameExists(value);
                    }
                  },
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    _navigateToCategoryListScreen();
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                      suffixIcon:
                          Icon(Icons.navigate_next), // Icono de navegación
                    ),
                    child: Text(
                      _selectedCategory.name.isNotEmpty
                          ? _selectedCategory.name
                          : '', // Mostrar nombre solo si no está vacío
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceUnitController,
                  decoration: const InputDecoration(
                    labelText: 'Precio Unitario',
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: 'S/. ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _validatePrice,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUnitSale,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedUnitSale = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Unidad de Venta',
                    prefixIcon: Icon(Icons.shopping_basket),
                  ),
                  items: <String>['Unidad', 'Kilo'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateStock,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateExpiryController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Expiracion',
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                  validator: _validateDateExpiry,
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isNewProduct ? 'Guardar Producto' : 'Guardar Cambios',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkNameExists(String value) async {
    try {
      bool nameExists = await ApiServiceProduct.checkExistingProduct(value);
      setState(() {
        _nameExists = nameExists;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar la existencia del nombre: $e'),
        ),
      );
    }
  }

  void _navigateToCategoryListScreen() async {
    final selectedCategory = await Navigator.push<Category?>(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryListScreen(),
      ),
    );

    if (selectedCategory != null) {
      setState(() {
        _selectedCategory = selectedCategory;
      });
    }
  }
}
