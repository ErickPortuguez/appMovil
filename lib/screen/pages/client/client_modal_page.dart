import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/client_model.dart';
import 'package:myapp/services/client_service.dart';

class ClientModalPage extends StatefulWidget {
  final Client client;
  final Function(Client, bool) onClientSaved;

  const ClientModalPage({
    super.key,
    required this.client,
    required this.onClientSaved,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ClientModalPageState createState() => _ClientModalPageState();
}

class _ClientModalPageState extends State<ClientModalPage> {
  late TextEditingController _numberDocumentController;
  late TextEditingController _namesController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _cellPhoneController;
  late TextEditingController _birthDateController;
  late DateTime _selectedDate;
  String _selectedDocumentType = 'DNI';
  bool _isNewClient = false;
  // ignore: prefer_final_fields
  bool _documentExists = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _numberDocumentController =
        TextEditingController(text: widget.client.numberDocument);
    _namesController = TextEditingController(text: widget.client.names);
    _lastNameController = TextEditingController(text: widget.client.lastName);
    _emailController = TextEditingController(text: widget.client.email);
    _cellPhoneController = TextEditingController(text: widget.client.cellPhone);
    _selectedDate = widget.client.birthDate ?? DateTime.now();
    _birthDateController = TextEditingController(
      text: widget.client.birthDate != null
          ? _formatDate(widget.client.birthDate!)
          : '',
    );

    _isNewClient = widget.client.id == 0;
    if (!_isNewClient) {
      _selectedDocumentType = widget.client.typeDocument;
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
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = _formatDate(picked);
      });
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    DateTime? selectedDate = _selectedDate;
    if (_birthDateController.text.isEmpty) {
      selectedDate = null;
    }

    final client = Client(
      id: widget.client.id,
      rolPerson: widget.client.rolPerson,
      typeDocument: _selectedDocumentType,
      numberDocument: _numberDocumentController.text,
      names: _namesController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      cellPhone: _cellPhoneController.text,
      birthDate: selectedDate,
      active: widget.client.active,
    );

    try {
      if (_isNewClient) {
        await ApiServiceClient.createClient(client);
      } else {
        await ApiServiceClient.updateClient(client);
      }

      widget.onClientSaved(client, _isNewClient);

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el cliente: $e'),
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
      if (value.isEmpty || value.length != 20) {
        return 'El CNE debe tener exactamente 20 dígitos';
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
    if (value != null && value.isNotEmpty) {
      final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(value)) {
        return 'Ingresa un correo electrónico válido';
      }
    }
    return null;
  }

  String? _validateCellPhone(String? value) {
    if (value != null && value.isNotEmpty) {
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
    }
    return null;
  }

  String? _validateBirthDate(String? value) {
    if (value != null && value.isNotEmpty) {
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final DateTime? birthDate = DateFormat('dd-MMM-yyyy').parse(value);
      if (birthDate == null) {
        return 'Fecha de nacimiento inválida';
      }

      final DateTime today = DateTime.now();
      final DateTime eighteenYearsAgo =
          DateTime(today.year - 18, today.month, today.day);

      if (birthDate.isAfter(eighteenYearsAgo)) {
        return 'Debes tener al menos 18 años';
      }
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
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 21, 0, 156), // Color del fondo del AppBar
        iconTheme: const IconThemeData(
            color: Colors.white), // Color de la flecha de retroceso
        title: Text(
          _isNewClient
              ? 'Nuevo Cliente'
              : '${widget.client.names} ${widget.client.lastName}',
          style: const TextStyle(
              color: Colors.white), // Color del texto del título
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode
                .onUserInteraction, // Activa la validación al interactuar con el usuario
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
                          await ApiServiceClient.checkExistingClient(value);
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
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    prefixIcon: Icon(Icons.cake),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                  validator: _validateBirthDate,
                ),
                const SizedBox(
                    height: 20), // Espacio entre el último campo y el botón
                Center(
                  child: SizedBox(
                    width: double.infinity, // Ancho máximo del botón
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Fondo del botón
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16), // Padding vertical
                      ),
                      child: Text(
                        _isNewClient ? 'Guardar Cliente' : 'Guardar Cambios',
                        style: const TextStyle(
                            fontSize: 20), // Tamaño de fuente del botón
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
