// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/seller_model.dart';
import 'package:myapp/services/seller_service.dart';

class SellerModalPage extends StatefulWidget {
  final Seller seller;
  final Function(Seller, bool) onSellerSaved;

  const SellerModalPage({
    super.key,
    required this.seller,
    required this.onSellerSaved,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SellerModalPageState createState() => _SellerModalPageState();
}

class _SellerModalPageState extends State<SellerModalPage> {
  late TextEditingController _numberDocumentController;
  late TextEditingController _namesController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _cellPhoneController;
  late TextEditingController _salaryController;
  late TextEditingController _sellerUserController;
  late TextEditingController _sellerPasswordController;

  String _selectedDocumentType = 'DNI';
  String _selectedSellerRol = 'Empleado';

  bool _isNewSeller = false;
  bool _documentExists = false;
  bool _obscurePassword = true; // Controla la visibilidad de la contraseña
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _numberDocumentController =
        TextEditingController(text: widget.seller.numberDocument);
    _namesController = TextEditingController(text: widget.seller.names);
    _lastNameController = TextEditingController(text: widget.seller.lastName);
    _emailController = TextEditingController(text: widget.seller.email);
    _cellPhoneController = TextEditingController(text: widget.seller.cellPhone);
    _salaryController = TextEditingController(
        text: widget.seller.salary > 0 ? widget.seller.salary.toString() : '');
    _sellerUserController =
        TextEditingController(text: widget.seller.sellerUser);
    _sellerPasswordController =
        TextEditingController(text: widget.seller.sellerPassword);

    _isNewSeller = widget.seller.id == 0;
    if (!_isNewSeller) {
      _selectedDocumentType = widget.seller.typeDocument;
      _selectedSellerRol = widget.seller.sellerRol;
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final seller = Seller(
      id: widget.seller.id,
      rolPerson: widget.seller.rolPerson,
      typeDocument: _selectedDocumentType,
      numberDocument: _numberDocumentController.text,
      names: _namesController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      cellPhone: _cellPhoneController.text,
      salary: double.parse(_salaryController.text),
      sellerRol: _selectedSellerRol,
      sellerUser: _sellerUserController.text,
      sellerPassword: _sellerPasswordController.text,
      active: widget.seller.active,
    );

    try {
      if (_isNewSeller) {
        await ApiServiceSeller.createSeller(seller);
      } else {
        await ApiServiceSeller.updateSeller(seller);
      }

      widget.onSellerSaved(seller, _isNewSeller);

      Navigator.of(context).pop(); // Cierra la pantalla de modal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el vendedor: $e'),
        ),
      );
    }
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
      if (value.isEmpty || value.length < 7 || value.length > 15) {
        return 'El CNE debe tener entre 7 y 15 dígitos';
      }
    }

    if (_documentExists) {
      return 'El número de documento ya está registrado';
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

  String? _validateSalary(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el salario';
    }

    final RegExp numericRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!numericRegex.hasMatch(value)) {
      return 'Ingresa un salario válido';
    }

    final salary = double.tryParse(value);
    if (salary == null || salary <= 0) {
      return 'Ingresa un salario válido';
    }

    return null;
  }

  String? _validateSellerUser(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el usuario';
    }
    return null;
  }

  String? _validateSellerPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la contraseña';
    }
    return null;
  }

  List<TextInputFormatter> _getInputFormatters() {
    return [FilteringTextInputFormatter.digitsOnly];
  }

  @override
  void dispose() {
    _numberDocumentController.dispose();
    _namesController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cellPhoneController.dispose();
    _salaryController.dispose();
    _sellerUserController.dispose();
    _sellerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isNewSeller
              ? 'Nuevo Vendedor'
              : '${widget.seller.names} ${widget.seller.lastName}',
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
                    prefixIcon: Icon(Icons.insert_drive_file),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: _getInputFormatters(),
                  onChanged: (value) async {
                    setState(() {
                      _documentExists = false;
                    });
                    if (value.isNotEmpty) {
                      bool documentExists =
                          await ApiServiceSeller.checkExistingSeller(value);
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
                  validator: _validateCellPhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salario',
                    prefixIcon: Icon(Icons.money),
                    prefixText: 'S/. ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateSalary,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSellerRol,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSellerRol = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Rol del Vendedor',
                    prefixIcon: Icon(Icons.description),
                  ),
                  items:
                      <String>['Empleado', 'Administrador'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sellerUserController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                  validator: _validateSellerUser,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sellerPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: _validateSellerPassword,
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
                        _isNewSeller ? 'Guardar Vendedor' : 'Guardar Cambios',
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
