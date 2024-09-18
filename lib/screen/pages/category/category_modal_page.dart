// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/models/category_model.dart';
import 'package:myapp/services/category_service.dart';

class CategoryModalPage extends StatefulWidget {
  final Category category;
  final Function(Category, bool) onCategorySaved;

  const CategoryModalPage({
    super.key,
    required this.category,
    required this.onCategorySaved,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CategoryModalPageState createState() => _CategoryModalPageState();
}

class _CategoryModalPageState extends State<CategoryModalPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isNewCategory = false;

  bool _nameExists = false; // Variable para verificar si el nombre ya existe
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController =
        TextEditingController(text: widget.category.description);

    _isNewCategory = widget.category.id == 0;

    // Verificar si el nombre inicial ya existe al inicio
    _checkNameExists(_nameController
        .text); // Llama al método _checkNameExists con el nombre inicial
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = Category(
      id: widget.category.id,
      name: _nameController.text,
      description: _descriptionController.text,
      active: widget.category.active,
    );

    try {
      if (_isNewCategory) {
        await ApiServiceCategory.createCategory(category);
      } else {
        await ApiServiceCategory.updateCategory(category);
      }

      widget.onCategorySaved(category, _isNewCategory);

      Navigator.of(context).pop(); // Cierra la pantalla de modal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la categoría: $e'),
        ),
      );
    }
  }

  String? _validateNames(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre';
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

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una descripción';
    }
    return null;
  }

  void _checkNameExists(String value) async {
    if (value.isNotEmpty) {
      bool nameExists = await ApiServiceCategory.checkExistingCategory(value);
      setState(() {
        _nameExists = nameExists;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isNewCategory ? 'Nueva Categoría' : widget.category.name,
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
                    prefixIcon: Icon(Icons.category),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) async {
                    // Limpiar la bandera de documento existente al cambiar el valor
                    setState(() {
                      _nameExists = false;
                    });
                    // Verificar si el documento existe al cambiar el valor
                    if (value.isNotEmpty) {
                      bool nameExists =
                          await ApiServiceCategory.checkExistingCategory(value);
                      setState(() {
                        _nameExists = nameExists;
                      });
                    }
                  },
                  validator:
                      _validateNames, // Valida el nombre según _nameExists
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: null, // Permite escribir varias líneas
                  keyboardType: TextInputType.multiline,
                  validator: _validateDescription,
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
                        _isNewCategory
                            ? 'Guardar Categoría'
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
