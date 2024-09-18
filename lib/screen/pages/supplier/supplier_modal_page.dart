// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/supplier_model.dart';
import 'package:myapp/services/supplier_service.dart';

class SupplierModalPage extends StatefulWidget {
  final Supplier supplier;
  final Function(Supplier, bool) onSupplierSaved;

  const SupplierModalPage({
    super.key,
    required this.supplier,
    required this.onSupplierSaved,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SupplierModalPageState createState() => _SupplierModalPageState();
}

class _SupplierModalPageState extends State<SupplierModalPage> {
  late TextEditingController _rucController;
  late TextEditingController _nameCompanyController;
  late TextEditingController _numberDocumentController;
  late TextEditingController _namesController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _cellPhoneController;
  String _selectedDocumentType = 'DNI';
  bool _isNewSupplier = false;
  bool _documentExists = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rucController = TextEditingController(text: widget.supplier.ruc);
    _nameCompanyController =
        TextEditingController(text: widget.supplier.nameCompany);
    _numberDocumentController =
        TextEditingController(text: widget.supplier.numberDocument);
    _namesController = TextEditingController(text: widget.supplier.names);
    _lastNameController = TextEditingController(text: widget.supplier.lastName);
    _emailController = TextEditingController(text: widget.supplier.email);
    _cellPhoneController =
        TextEditingController(text: widget.supplier.cellPhone);
    _isNewSupplier = widget.supplier.id == 0;
    if (!_isNewSupplier) {
      _selectedDocumentType = widget.supplier.typeDocument;
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final supplier = Supplier(
      id: widget.supplier.id,
      ruc: _rucController.text,
      nameCompany: _nameCompanyController.text,
      typeDocument: _selectedDocumentType,
      numberDocument: _numberDocumentController.text,
      names: _namesController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      cellPhone: _cellPhoneController.text,
      active: widget.supplier.active,
    );

    try {
      if (_isNewSupplier) {
        await ApiServiceSupplier.createSupplier(supplier);
      } else {
        await ApiServiceSupplier.updateSupplier(supplier);
      }

      widget.onSupplierSaved(supplier, _isNewSupplier);

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el proveedor: $e'),
        ),
      );
    }
  }

  String? _validateRuc(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el RUC';
    }

    if (value.isEmpty || value.length != 11) {
      return 'El RUC debe tener exactamente 11 dígitos';
    }

    return null;
  }

  String? _validateNumberDocument(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el número de documento';
    }
    if (_selectedDocumentType == 'DNI') {
      if (value.isEmpty || value.length != 8) {
        return 'El DNI debe tener exactamente 8 dígitos';
      }
    } else if (_selectedDocumentType == 'CNE') {
      if (value.isEmpty || value.length != 20) {
        return 'El CNE debe tener exactamente 20 dígitos';
      }
    }

    if (_documentExists) {
      return 'El número de documento ya está registrado';
    }

    return null;
  }

  String? _validateNameCompany(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre de la empresa';
    }
    return null;
  }

  String? _validateNames(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa los nombres';
    }
    final RegExp nameRegExp = RegExp(r'^[a-zA-Záéíóúüñ\s]+$');
    if (!nameRegExp.hasMatch(value)) {
      return 'Ingresa solo letras en los nombres';
    }
    final words = value.split(' ');
    for (final word in words) {
      if (word.isEmpty || word[0] != word[0].toUpperCase()) {
        return 'Cada palabra debe empezar con mayúscula';
      }
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa los apellidos';
    }
    final RegExp lastNameRegExp = RegExp(r'^[a-zA-Záéíóúüñ\s]+$');
    if (!lastNameRegExp.hasMatch(value)) {
      return 'Ingresa solo letras en los apellidos';
    }
    final words = value.split(' ');
    for (final word in words) {
      if (word.isEmpty || word[0] != word[0].toUpperCase()) {
        return 'Cada palabra debe empezar con mayúscula';
      }
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el correo electrónico';
    }
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validateCellPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el número de teléfono';
    }
    final RegExp digitsOnlyRegExp = RegExp(r'^\d+$');
    if (!digitsOnlyRegExp.hasMatch(value)) {
      return 'El número de teléfono debe contener solo números';
    }
    if (!value.startsWith('9')) {
      return 'El número de teléfono debe comenzar con 9';
    }
    if (value.length != 9) {
      return 'El número de teléfono debe tener 9 dígitos';
    }
    return null;
  }

  List<TextInputFormatter> _getInputFormatters() {
    return [FilteringTextInputFormatter.digitsOnly];
  }

  @override
  void dispose() {
    _rucController.dispose();
    _nameCompanyController.dispose();
    _numberDocumentController.dispose();
    _namesController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cellPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isNewSupplier
              ? 'Nuevo Proveedor'
              : '${widget.supplier.names} ${widget.supplier.lastName}',
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
                  controller: _rucController,
                  decoration: const InputDecoration(
                    labelText: 'RUC',
                    prefixIcon: Icon(Icons.business),
                  ),
                  inputFormatters: _getInputFormatters(),
                  keyboardType: TextInputType.number,
                  validator: _validateRuc,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCompanyController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Empresa',
                    prefixIcon: Icon(Icons.business_center),
                  ),
                  validator: _validateNameCompany,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDocumentType,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDocumentType = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Documento',
                    prefixIcon: Icon(Icons.account_box),
                  ),
                  items: <String>['DNI', 'CNE'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numberDocumentController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Documento',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  inputFormatters: _getInputFormatters(),
                  onChanged: (value) async {
                    // Limpiar la bandera de documento existente al cambiar el valor
                    setState(() {
                      _documentExists = false;
                    });
                    // Verificar si el documento existe al cambiar el valor
                    if (value.isNotEmpty) {
                      bool documentExists =
                          await ApiServiceSupplier.checkExistingSupplier(value);
                      setState(() {
                        _documentExists = documentExists;
                      });
                    }
                  },
                  validator: _validateNumberDocument,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namesController,
                  decoration: const InputDecoration(
                    labelText: 'Nombres',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: _validateNames,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Apellidos',
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: _validateLastName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cellPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateCellPhone,
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
                        _isNewSupplier
                            ? 'Guardar Proveedor'
                            : 'Guardar Cambios',
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
}
